import CurrentUser from './current_user'
import Utility from './utility'

let Note = {
  HIDE_DELAY: 250,
  NORMALIZE_ATTRIBUTES: ['letter-spacing', 'line-height', 'margin-left', 'margin-right', 'margin-top', 'margin-bottom', 'padding-left', 'padding-right', 'padding-top', 'padding-bottom'],
  COPY_ATTRIBUTES: ['background-color', 'border-radius', 'transform', 'justify-content', 'align-items'],
  permitted_style_values: function(attribute, $attribute_child) {
    if ($attribute_child.length === 0) {
      return "";
    }
    let found_attribute = $attribute_child.attr('style').split(';').filter(val => val.match(RegExp(`(^| )${attribute}:`)));
    if (found_attribute.length === 0) {
      return "";
    }
    let [, value] = found_attribute[0].trim().split(':').map(val => val.trim());
    if (attribute === "background-color") {
      const color_code = $attribute_child.css('background-color');
      return color_code.startsWith('rgba') ? "" : value;
    }
    if (attribute === "transform") {
      let rotate_match = value.match(/rotate\([^)]+\)/);
      return rotate_match ? rotate_match[0] : "";
    }
    return value;
  },

  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");

      var $note_box = $('<div/>');
      $note_box.addClass("note-box");

      if (Note.embed) {
        $note_box.addClass("embedded");
      }

      $note_box.data("id", String(id));
      $note_box.attr("data-id", String(id));
      $note_box.draggable({
        containment: $("#image"),
        stop: function(e, ui) {
          Note.Box.update_data_attributes($note_box);
        }
      });
      $note_box.resizable({
        containment: $("#image"),
        handles: "se, nw",
        stop: function(e, ui) {
          Note.Box.update_data_attributes($note_box);
        }
      });
      $note_box.css({position: "absolute"});
      $note_box.append($inner_border);
      Note.Box.bind_events($note_box);

      return $note_box;
    },

    update_data_attributes: function($note_box) {
      var $image = $("#image");
      var ratio = $image.width() / parseFloat($image.data("original-width"));
      var new_x = parseFloat($note_box.css("left"));
      var new_y = parseFloat($note_box.css("top"));
      var new_width = parseFloat($note_box.css("width"));
      var new_height = parseFloat($note_box.css("height"));
      new_x = parseInt(new_x / ratio);
      new_y = parseInt(new_y / ratio);
      new_width = parseInt(new_width / ratio);
      new_height = parseInt(new_height / ratio);
      $note_box.data("x", new_x);
      $note_box.data("y", new_y);
      $note_box.data("width", new_width);
      $note_box.data("height", new_height);
    },

    copy_style_attributes: function($note_box) {
      const $attribute_child = $note_box.find('.note-box-attributes');
      let has_rotation = false;
      Note.COPY_ATTRIBUTES.forEach((attribute)=>{
        const attribute_value = Note.permitted_style_values(attribute, $attribute_child);
        $note_box.css(attribute, attribute_value);
        if (attribute === "transform" && attribute_value.startsWith("rotate")) {
          has_rotation = true;
        }
      });
      if (has_rotation) {
        const current_left = Math.round(parseFloat($note_box.css("left")));
        const current_top = Math.round(parseFloat($note_box.css("top")));
        const position = Note.Box.get_min_max_position($note_box);
        // Checks for the scenario where the user sets invalid box values through the API
        // or by adjusting the box dimensions through the browser's dev console before saving
        if (current_left !== position.norm_left || current_top !== position.norm_top) {
          $note_box.css({
            top: position.percent_top,
            left: position.percent_left,
          });
          $note_box.addClass("out-of-bounds");
        } else {
          $note_box.removeClass("out-of-bounds");
        }
        $note_box.data('has_rotation', true);
      } else {
        $note_box.data('has_rotation', false);
      }
    },

    bind_events: function($note_box) {
      $note_box.on(
        "dragstart.danbooru resizestart.danbooru",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          $note_box_inner.addClass("unsaved");
          Note.dragging = true;
          Note.clear_timeouts();
          Note.Body.hide_all();
          e.stopPropagation();
        }
      );

      $note_box.on(
        "dragstop.danbooru resizestop.danbooru",
        function(e) {
          Note.dragging = false;
          e.stopPropagation();
        }
      );

      $note_box.on(
        "mouseover.danbooru mouseout.danbooru",
        function(e) {
          if (Note.dragging || Utility.test_max_width(660)) {
            return;
          }

          var $this = $(this);
          var $note_box_inner = $(e.currentTarget);

          const note_id = $note_box_inner.data("id");
          if (e.type === "mouseover") {
            Note.Body.show(note_id);
            if (Note.editing) {
              $this.resizable("enable");
              $this.draggable("enable");
            }
            $note_box.addClass("hovering");
          } else if (e.type === "mouseout") {
            Note.Body.hide(note_id);
            if (Note.editing) {
              $this.resizable("disable");
              $this.draggable("disable");
            }
            $note_box.removeClass("hovering");
          }

          e.stopPropagation();
        }
      );

      $note_box.on(
        "click.danbooru",
        function (event) {
          const note_id = $note_box.data("id");
          if (!Utility.test_max_width(660)) {
            $(".note-box").removeClass("movable");
            if (note_id === Note.move_id) {
              Note.move_id = null;
            } else {
              Note.move_id = note_id;
              $note_box.addClass("movable");
            }
          } else if ($note_box.hasClass("viewing")) {
            Note.Body.hide(note_id);
            $note_box.removeClass("viewing");
          } else {
            $(".note-box").removeClass("viewing");
            Note.Body.show(note_id);
            $note_box.addClass("viewing");
          }
        }
      );

      $note_box.on("mousedown.danbooru", function(event) {
        Note.drag_id = $note_box.data('id');
      });

      $note_box.on("mouseup.danbooru.drag", Note.Box.drag_stop);
    },

    find: function(id) {
      return $(".note-container div.note-box[data-id=" + id + "]");
    },

    drag_stop: function(event) {
      if (Note.drag_id !== null) {
        const $image = $("#image");
        const $note_box = Note.Box.find(Note.drag_id);
        const dimensions = {
          top: (100 * ($note_box.position().top / $image.height())) + '%',
          left: (100 * ($note_box.position().left / $image.width())) + '%',
          height: (100 * ($note_box.height() / $image.height())) + '%',
          width: (100 * ($note_box.width() / $image.width())) + '%',
        };
        if (Note.embed && $note_box.data('has_rotation')) {
          const position = Note.Box.get_min_max_position($note_box);
          Object.assign(dimensions, {
            top: position.percentage_top,
            left: position.percentage_left,
          });
        }
        $note_box.css(dimensions);
        Note.drag_id = null;
      }
    },

    key_nudge: function(event) {
      if (!Note.move_id) {
        return;
      }
      const $note_box = Note.Box.find(Note.move_id);
      if ($note_box.length === 0) {
        return;
      }
      let computed_style = window.getComputedStyle($note_box[0]);
      let current_top = Math.round(parseFloat(computed_style.top));
      let current_left = Math.round(parseFloat(computed_style.left));
      switch (event.originalEvent.key) {
      case "ArrowUp":
        current_top--;
        break;
      case "ArrowDown":
        current_top++;
        break;
      case "ArrowLeft":
        current_left--;
        break;
      case "ArrowRight":
        current_left++;
        break;
      default:
        // do nothing
      }
      let position = Note.Box.get_min_max_position($note_box, current_top, current_left);
      $note_box.css({
        top: position.percent_top,
        left: position.percent_left,
      });
      $note_box.addClass("unsaved");
      event.preventDefault();
    },

    key_resize: function (event) {
      if (!Note.move_id) {
        return;
      }
      const $note_box = Note.Box.find(Note.move_id);
      if ($note_box.length === 0) {
        return;
      }
      let computed_style = window.getComputedStyle($note_box[0]);
      let current_top = Math.round(parseFloat(computed_style.top));
      let current_left = Math.round(parseFloat(computed_style.left));
      let current_height = $note_box.height();
      let current_width = $note_box.width();
      switch (event.originalEvent.key) {
      case "ArrowUp":
        current_height--;
        break;
      case "ArrowDown":
        current_height++;
        break;
      case "ArrowLeft":
        current_width--;
        break;
      case "ArrowRight":
        current_width++;
        break;
      default:
        // do nothing
      }
      const position = Note.Box.get_min_max_position($note_box, null, null, current_height, current_width);
      if (current_top === position.norm_top && current_left === position.norm_left) {
        $note_box.css({
          height: current_height,
          width: current_width,
        });
      }
      $note_box.addClass("unsaved");
      event.preventDefault();
    },

    get_min_max_position: function($note_box, current_top = null, current_left = null, current_height = null, current_width = null) {
      const computed_style = window.getComputedStyle($note_box[0]);
      current_top = (current_top === null ? parseFloat(computed_style.top) : current_top);
      current_left = (current_left === null ? parseFloat(computed_style.left) : current_left);
      current_height = current_height || $note_box.height();
      current_width = current_width || $note_box.width();
      const $image = $("#image");
      const image_height = $image.height();
      const image_width = $image.width();
      const box_data = Note.Box.get_bounding_box($note_box, current_height, current_width);
      if (((box_data.max_x - box_data.min_x) <= image_width) && ((box_data.max_y - box_data.min_y) <= image_height)) {
        current_top = Math.min(Math.max(current_top, -box_data.min_y, 0), image_height - box_data.max_y - 2, image_height - box_data.min_y - box_data.max_y - 2, image_height);
        current_left = Math.min(Math.max(current_left, -box_data.min_x, 0), image_width - box_data.max_x - 2, image_width - box_data.min_x - box_data.max_x - 2, image_width);
      } else {
        Utility.error("Box too large to be rotated!");
        $note_box.css('transform', 'none');
      }
      return {
        norm_top: Math.round(current_top),
        norm_left: Math.round(current_left),
        percent_top: (100 * (current_top / $image.height())) + '%',
        percent_left: (100 * (current_left / $image.width())) + '%',
      };
    },

    get_bounding_box: function($note_box, height = null, width = null) {
      height = height || $note_box.height();
      width = width || $note_box.width();
      let old_coord = [[0, 0], [width, 0], [0, height], [width, height]];
      const computed_style = window.getComputedStyle($note_box[0]);
      const match = computed_style.transform.match(/matrix\(([-e0-9.]+), ([-e0-9.]+)/);
      if (!match) {
        return {
          min_x: 0,
          min_y: 0,
          max_x: width,
          max_y: height,
          norm_coord: old_coord,
          degrees: 0,
        }
      }
      const costheta = Math.round(match[1] * 1000) / 1000;
      const sintheta = Math.round(match[2] * 1000) / 1000;
      let trans_x = width / 2;
      let trans_y = height / 2;
      let min_x = Infinity;
      let max_x = 0;
      let min_y = Infinity;
      let max_y = 0;
      const new_coord = old_coord.map((coord)=>{
        let temp_x = coord[0] - trans_x;
        let temp_y = coord[1] - trans_y;
        let rotated_x = (temp_x * costheta) - (temp_y * sintheta);
        let rotated_y = (temp_x * sintheta) + (temp_y * costheta);
        let new_x = rotated_x + trans_x;
        let new_y = rotated_y + trans_y;
        min_x = Math.min(min_x, new_x);
        max_x = Math.max(max_x, new_x);
        min_y = Math.min(min_y, new_y);
        max_y = Math.max(max_y, new_y);
        return [new_x, new_y];
      });
      const norm_coord = new_coord.map((coord)=>{
        return [coord[0] - min_x, coord[1] - min_y];
      });
      const radians_per_degree = 0.017453292519943295;
      const degrees = Math.asin(sintheta) / radians_per_degree;
      return {
        min_x: min_x,
        min_y: min_y,
        max_x: max_x,
        max_y: max_y,
        norm_coord: norm_coord,
        degrees: degrees,
      };
    },

    show_highlighted: function($note_box) {
      var note_id = $note_box.data("id");

      Note.Body.show(note_id);
      $(".note-box-highlighted").removeClass("note-box-highlighted");
      $note_box.addClass("note-box-highlighted");
      $note_box[0].scrollIntoView(false);
    },

    scale: function($note_box) {
      var $image = $("#image");
      var original_width = $image.data("original-width");
      var original_height = $image.data("original-height");
      var x_percent = 100 * ($note_box.data('x') / original_width);
      var y_percent = 100 * ($note_box.data('y') / original_height);
      var height_percent = 100 * ($note_box.data('height') / original_height);
      var width_percent = 100 * ($note_box.data('width') / original_width);
      $note_box.css({
        top: y_percent + '%',
        left: x_percent + '%',
        width: width_percent + '%',
        height: height_percent + '%',
      });
    },

    scale_all: function() {
      const $container = $('.note-container');
      if ($container.length === 0) {
        return;
      }
      let $image = $("#image");
      if (Note.embed) {
        let large_width = parseFloat($image.data('large-width'));
        let ratio = $image.width() / large_width;
        let font_percentage = ratio * 100;
        $container.css('font-size', font_percentage + '%');
      }
    },

    toggle_all: function() {
      $(".note-container").toggleClass("hide-notes");
    }
  },

  Body: {
    create: function(id) {
      var $note_body = $('<div></div>');
      $note_body.addClass("note-body");
      $note_body.data("id", String(id));
      $note_body.attr("data-id", String(id));
      $note_body.hide();
      Note.Body.bind_events($note_body);
      return $note_body;
    },

    initialize: function($note_body) {
      var $note_box = Note.Box.find($note_body.data("id"));
      if (Note.embed && $note_box.data('has_rotation')) {
        const box_data = Note.Box.get_bounding_box($note_box);
        // Select the lowest box corner to the farthest left
        let selected_corner = box_data.norm_coord.reduce(function (selected, coord) {return (selected[1] > coord[1]) || (selected[1] === coord[1] && selected[0] < coord[0]) ? selected : coord;});
        let normalized_degrees = box_data.degrees % 90.0;
        // Align to the left or right body corner depending upon the box angle
        let body_corner = $note_box.position().left - (normalized_degrees > 0.0 && normalized_degrees <= 45.0 ? $note_body.width() : 0);
        $note_body.css({
          top: $note_box.position().top + selected_corner[1] + 5,
          left: body_corner + selected_corner[0],
        });
      } else {
        $note_body.css({
          top: $note_box.position().top + $note_box.height() + 5,
          left: $note_box.position().left,
        });
      }
      Note.Body.bound_position($note_body);
    },

    bound_position: function($note_body) {
      var $image = $("#image");
      var doc_width = $image.offset().left + $image.width();

      if ($note_body.offset().left + $note_body.width() > doc_width) {
        $note_body.css({
          left: $note_body.position().left - 10 - ($note_body.offset().left + $note_body.width() - doc_width)
        });
      }
    },

    show: function(id) {
      Note.Body.hide_all();
      Note.clear_timeouts();
      var $note_body = Note.Body.find(id);
      if (!$note_body.data('resized')) {
        Note.Body.resize($note_body);
        $note_body.data('resized', 'true');
      }
      $note_body.show();
      Note.Body.initialize($note_body);
    },

    find: function(id) {
      return $(".note-container div.note-body[data-id=" + id + "]");
    },

    hide: function(id) {
      var $note_body = Note.Body.find(id);
      Note.timeouts.push(setTimeout(() => $note_body.hide(), Note.HIDE_DELAY));
    },

    hide_all: function() {
      $(".note-container div.note-body").hide();
    },

    resize: function($note_body) {
      $note_body.css("min-width", "");
      var w = $note_body.width();
      var h = $note_body.height();
      var golden_ratio = 1.6180339887;
      var last = 0;
      var x = 0;
      var lo = 0;
      var hi = 0;

      if ((w / h) < golden_ratio) {
        lo = 140;
        hi = 400;

        do {
          last = w;
          x = (lo + hi) / 2;
          $note_body.css("min-width", x);
          w = $note_body.width();
          h = $note_body.height();

          if ((w / h) < golden_ratio) {
            lo = x;
          } else {
            hi = x;
          }
        } while ((lo < hi) && (w > last));
      } else if ($note_body[0].scrollWidth <= $note_body.width()) {
        lo = 20;
        hi = w;

        do {
          x = (lo + hi) / 2;
          $note_body.css("min-width", x);
          if ($note_body.height() > h) {
            lo = x
          } else {
            hi = x;
          }
        } while ((hi - lo) > 4);
        if ($note_body.height() > h) {
          $note_body.css("min-width", hi);
        }
      }
    },

    set_text: function($note_body, $note_box, text) {
      if (Note.embed) {
        const $note_inner_box = $note_box.find("div.note-box-inner-border");
        Note.Body.display_text($note_inner_box, text);
        // Reset the font size so that the normalization calculations will be correct
        $note_inner_box.css("font-size", Note.base_font_size + "px");
        Note.normalize_sizes($note_inner_box.children(), Note.base_font_size);
        // Clear the font size so that the fonts will be scaled to the current value
        $note_inner_box.css("font-size", "");
        Note.Box.copy_style_attributes($note_box);
      } else {
        Note.Body.display_text($note_body, text);
      }
      Note.Body.resize($note_body);
      Note.Body.bound_position($note_body);
    },

    display_text: function($note_body, text) {
      text = text.replace(/<tn>/g, '<p class="tn">');
      text = text.replace(/<\/tn>/g, '</p>');
      text = text.replace(/\n/g, '<br>');
      $note_body.html(text);
    },

    bind_events: function($note_body) {
      $note_body.on("mouseover.danbooru", function(e) {
        var $note_body_inner = $(e.currentTarget);
        Note.Body.show($note_body_inner.data("id"));
        e.stopPropagation();
      });

      $note_body.on("mouseout.danbooru", function(e) {
        var $note_body_inner = $(e.currentTarget);
        Note.Body.hide($note_body_inner.data("id"));
        e.stopPropagation();
      });

      if (CurrentUser.data("is-anonymous") === false) {
        $note_body.on("click.danbooru", function(e) {
          if (e.target.tagName !== "A") {
            var $note_body_inner = $(e.currentTarget);
            Note.Edit.show($note_body_inner);
          }
          e.stopPropagation();
        });
      } else {
        $note_body.on("click.danbooru", function(e) {
          if (e.target.tagName !== "A") {
            Utility.notice("You must be logged in to edit notes");
          }
          e.stopPropagation();
        });
      }
    }
  },

  Edit: {
    show: function($note_body) {
      var id = $note_body.data("id");

      if (Note.editing) {
        return;
      }

      $(".note-box").resizable("disable");
      $(".note-box").draggable("disable");
      $(".note-box").addClass("editing");

      let $textarea = $('<textarea></textarea>');
      $textarea.css({
        width: "97%",
        height: "85%",
        resize: "none",
      });

      if ($note_body.html() !== "<em>Click to edit</em>") {
        $textarea.val($note_body.data("original-body"));
      }

      let $dialog = $('<div></div>');
      let note_title = (typeof id === 'string' && id.startsWith('x') ? 'Creating new note' : 'Editing note #' + id);
      $dialog.append('<span><b>' + note_title + ' (<a href="/wiki_pages/help:notes">view help</a>)</b></span>');
      $dialog.append($textarea);
      $dialog.data("id", id);
      $dialog.dialog({
        width: 360,
        height: 240,
        position: {
          my: "right",
          at: "right-20",
          of: window
        },
        classes: {
          "ui-dialog": "note-edit-dialog",
        },
        buttons: {
          "Save": Note.Edit.save,
          "Preview": Note.Edit.preview,
          "Cancel": Note.Edit.cancel,
          "Delete": Note.Edit.destroy,
          "History": Note.Edit.history
        }
      });
      $dialog.data("uiDialog")._title = function(title) {
        title.html(this.options.title); // Allow unescaped html in dialog title
      }

      $dialog.on("dialogclose.danbooru", function() {
        Note.editing = false;
        $(".note-box").resizable("enable");
        $(".note-box").draggable("enable");
        $(".note-box").removeClass("editing");
      });

      $textarea.selectEnd();
      Note.editing = true;
    },

    parameterize_note: function($note_box, $note_body) {
      var $image = $("#image");
      var original_width = parseInt($image.data("original-width"));
      var ratio = parseInt($image.width()) / original_width;

      var hash = {
        note: {
          x: Math.round($note_box.position().left / ratio),
          y: Math.round($note_box.position().top / ratio),
          width: Math.round($note_box.width() / ratio),
          height: Math.round($note_box.height() / ratio),
          body: $note_body.data("original-body"),
        }
      }

      if ($note_box.data("id").match(/x/)) {
        hash.note.html_id = $note_box.data("id");
        hash.note.post_id = Utility.meta("post-id");
      }

      return hash;
    },

    error_handler: function(xhr, status, exception) {
      Utility.error("Error: " + (xhr.responseJSON.reason || xhr.responseJSON.reasons.join("; ")));
    },

    success_handler: function(data, status, xhr) {
      var $note_box = null;

      if (data.html_id) { // new note
        var $note_body = Note.Body.find(data.html_id);
        $note_box = Note.Box.find(data.html_id);
        $note_body.data("id", String(data.id)).attr("data-id", data.id);
        $note_box.data("id", String(data.id)).attr("data-id", data.id);
        $note_box.removeClass("unsaved");
        $note_box.removeClass("movable");
      } else {
        $note_box = Note.Box.find(data.id);
        $note_box.removeClass("unsaved");
        $note_box.removeClass("movable");
      }
      Note.move_id = null;
    },

    save: function() {
      var $this = $(this);
      var $textarea = $this.find("textarea");
      var id = $this.data("id");
      var $note_body = Note.Body.find(id);
      var $note_box = Note.Box.find(id);
      var text = $textarea.val();
      $note_body.data("original-body", text);
      Note.Body.set_text($note_body, $note_box, "Loading...");
      $.get("/note_previews.json", {body: text}).then(function(data) {
        Note.Body.set_text($note_body, $note_box, data.body);
        Note.Body.initialize($note_body);
        $note_body.show();
      });
      $this.dialog("close");

      if (id.match(/\d/)) {
        $.ajax("/notes/" + id + ".json", {
          type: "PUT",
          data: Note.Edit.parameterize_note($note_box, $note_body),
          error: Note.Edit.error_handler,
          success: Note.Edit.success_handler
        });
      } else {
        $.ajax("/notes.json", {
          type: "POST",
          data: Note.Edit.parameterize_note($note_box, $note_body),
          error: Note.Edit.error_handler,
          success: Note.Edit.success_handler
        });
      }
    },

    preview: function() {
      var $this = $(this);
      var $textarea = $this.find("textarea");
      var id = $this.data("id");
      var $note_body = Note.Body.find(id);
      var text = $textarea.val();
      var $note_box = Note.Box.find(id);
      $note_box.addClass("unsaved");
      Note.Body.set_text($note_body, $note_box, "Loading...");
      $.get("/note_previews.json", {body: text}).then(function(data) {
        Note.Body.set_text($note_body, $note_box, data.body);
        Note.Body.initialize($note_body);
        $note_body.show();
      });
    },

    cancel: function() {
      $(this).dialog("close");
    },

    destroy: function() {
      if (!confirm("Do you really want to delete this note?")) {
        return
      }

      var $this = $(this);
      var id = $this.data("id");

      if (id.match(/\d/)) {
        $.ajax("/notes/" + id + ".json", {
          type: "DELETE",
          success: function() {
            Note.Box.find(id).remove();
            Note.Body.find(id).remove();
            $this.dialog("close");
          }
        });
      }
    },

    history: function() {
      var $this = $(this);
      var id = $this.data("id");
      if (id.match(/\d/)) {
        window.location.href = "/note_versions?search[note_id]=" + id;
      }
      $(this).dialog("close");
    }
  },

  TranslationMode: {
    active: false,

    toggle: function(e) {
      if (Note.TranslationMode.active) {
        Note.TranslationMode.stop(e);
      } else {
        Note.TranslationMode.start(e);
      }
    },

    start: function(e) {
      e.preventDefault();

      if (CurrentUser.data("is-anonymous")) {
        Utility.notice("You must be logged in to edit notes");
        return;
      }

      if (Note.TranslationMode.active) {
        return;
      }

      $("#image").css("cursor", "crosshair");
      Note.TranslationMode.active = true;
      $(document.body).addClass("mode-translation");
      $("#image").off("click.danbooru", Note.Box.toggle_all);
      $("#image").on("mousedown.danbooru.note", Note.TranslationMode.Drag.start);
      $(document).on("mouseup.danbooru.note", Note.TranslationMode.Drag.stop);
      $("#mark-as-translated-section").show();

      Utility.notice('Translation mode is on. Drag on the image to create notes. <a href="#">Turn translation mode off</a> (shortcut is <span class="key">n</span>).');
      $("#notice a:contains(Turn translation mode off)").on("click.danbooru", Note.TranslationMode.stop);
    },

    stop: function(e) {
      e.preventDefault();

      Note.TranslationMode.active = false;
      $("#image").css("cursor", "auto");
      $("#image").on("click.danbooru", Note.Box.toggle_all);
      $("#image").off("mousedown.danbooru.note", Note.TranslationMode.Drag.start);
      $(document).off("mouseup.danbooru.note", Note.TranslationMode.Drag.stop);
      $(document.body).removeClass("mode-translation");
      $("#close-notice-link").click();
      $("#mark-as-translated-section").hide();
    },

    create_note: function(e, x, y, w, h) {
      if (w > 9 || h > 9) { /* minimum note size: 10px */
        if (w <= 9) {
          w = 10;
        } else if (h <= 9) {
          h = 10;
        }
        Note.create(x, y, w, h);
      }

      $(".note-container").removeClass("hide-notes");
      e.stopPropagation();
      e.preventDefault();
    },

    Drag: {
      dragging: false,
      dragStartX: 0,
      dragStartY: 0,
      dragDistanceX: 0,
      dragDistanceY: 0,
      x: 0,
      y: 0,
      w: 0,
      h: 0,

      start: function (e) {
        if (e.which !== 1) {
          return;
        }
        e.preventDefault(); /* don't drag the image */
        $(document).on("mousemove.danbooru", Note.TranslationMode.Drag.drag);
        Note.TranslationMode.Drag.dragStartX = e.pageX;
        Note.TranslationMode.Drag.dragStartY = e.pageY;
      },

      drag: function (e) {
        Note.TranslationMode.Drag.dragDistanceX = e.pageX - Note.TranslationMode.Drag.dragStartX;
        Note.TranslationMode.Drag.dragDistanceY = e.pageY - Note.TranslationMode.Drag.dragStartY;
        var $image = $("#image");
        var offset = $image.offset();
        var limitX1 = $image.width() - Note.TranslationMode.Drag.dragStartX + offset.left - 1;
        var limitX2 = offset.left - Note.TranslationMode.Drag.dragStartX;
        var limitY1 = $image.height() - Note.TranslationMode.Drag.dragStartY + offset.top - 1;
        var limitY2 = offset.top - Note.TranslationMode.Drag.dragStartY;

        if (Note.TranslationMode.Drag.dragDistanceX > limitX1) {
          Note.TranslationMode.Drag.dragDistanceX = limitX1;
        } else if (Note.TranslationMode.Drag.dragDistanceX < limitX2) {
          Note.TranslationMode.Drag.dragDistanceX = limitX2;
        }

        if (Note.TranslationMode.Drag.dragDistanceY > limitY1) {
          Note.TranslationMode.Drag.dragDistanceY = limitY1;
        } else if (Note.TranslationMode.Drag.dragDistanceY < limitY2) {
          Note.TranslationMode.Drag.dragDistanceY = limitY2;
        }

        if (Math.abs(Note.TranslationMode.Drag.dragDistanceX) > 9 && Math.abs(Note.TranslationMode.Drag.dragDistanceY) > 9) {
          Note.TranslationMode.Drag.dragging = true; /* must drag at least 10pixels (minimum note size) in both dimensions. */
        }
        if (Note.TranslationMode.Drag.dragging) {
          if (Note.TranslationMode.Drag.dragDistanceX >= 0) {
            Note.TranslationMode.Drag.x = Note.TranslationMode.Drag.dragStartX - offset.left;
            Note.TranslationMode.Drag.w = Note.TranslationMode.Drag.dragDistanceX;
          } else {
            Note.TranslationMode.Drag.x = Note.TranslationMode.Drag.dragStartX - offset.left + Note.TranslationMode.Drag.dragDistanceX;
            Note.TranslationMode.Drag.w = -Note.TranslationMode.Drag.dragDistanceX;
          }

          if (Note.TranslationMode.Drag.dragDistanceY >= 0) {
            Note.TranslationMode.Drag.y = Note.TranslationMode.Drag.dragStartY - offset.top;
            Note.TranslationMode.Drag.h = Note.TranslationMode.Drag.dragDistanceY;
          } else {
            Note.TranslationMode.Drag.y = Note.TranslationMode.Drag.dragStartY - offset.top + Note.TranslationMode.Drag.dragDistanceY;
            Note.TranslationMode.Drag.h = -Note.TranslationMode.Drag.dragDistanceY;
          }

          $('#note-preview').css({
            display: 'block',
            left: (Note.TranslationMode.Drag.x + 1),
            top: (Note.TranslationMode.Drag.y + 1),
            width: (Note.TranslationMode.Drag.w - 3),
            height: (Note.TranslationMode.Drag.h - 3)
          });
        }
      },

      stop: function (e) {
        if (e.which !== 1) {
          return;
        }
        if (Note.TranslationMode.Drag.dragStartX === 0) {
          return; /* 'stop' is bound to window, don't create note if start wasn't triggered */
        }
        $(document).off("mousemove.danbooru", Note.TranslationMode.Drag.drag);

        if (Note.TranslationMode.Drag.dragging) {
          $('#note-preview').css({ display: 'none' });
          Note.TranslationMode.create_note(e, Note.TranslationMode.Drag.x, Note.TranslationMode.Drag.y, Note.TranslationMode.Drag.w - 1, Note.TranslationMode.Drag.h - 1);
          Note.TranslationMode.Drag.dragging = false; /* border of the note is pixel-perfect on the preview border */
        } else { /* no dragging -> toggle display of notes */
          Note.Box.toggle_all();
        }

        Note.TranslationMode.Drag.dragStartX = 0;
        Note.TranslationMode.Drag.dragStartY = 0;
      }
    }
  },

  id: "x",
  dragging: false,
  editing: false,
  move_id: null,
  drag_id: null,
  base_font_size: null,
  timeouts: [],
  pending: {},

  add: function(container, id, x, y, w, h, original_body, sanitized_body) {
    var $note_box = Note.Box.create(id);
    var $note_body = Note.Body.create(id);

    $note_box.data('x', x);
    $note_box.data('y', y);
    $note_box.data('width', w);
    $note_box.data('height', h);
    container.appendChild($note_box[0]);
    container.appendChild($note_body[0]);
    $note_body.data("original-body", original_body);
    Note.Box.scale($note_box);
    if (Note.embed) {
      Note.Body.display_text($note_box.children("div.note-box-inner-border"), sanitized_body);
      Note.Body.display_text($note_body, "Click to edit.");
    } else {
      Note.Body.display_text($note_body, sanitized_body);
    }
  },

  create: function(x, y, w, h) {
    var $note_box = Note.Box.create(Note.id);
    var $note_body = Note.Body.create(Note.id);
    $note_box.css({
      top: y,
      left: x,
      width: w,
      height: h
    });
    Note.Box.update_data_attributes($note_box);
    $note_box.addClass("unsaved");
    $note_body.html("<em>Click to edit</em>");
    $(".note-container").append($note_box);
    $(".note-container").append($note_body);
    Note.id += "x";
  },

  normalize_sizes: function ($note_elements, parent_font_size) {
    if ($note_elements.length === 0) {
      return;
    }
    $note_elements.each(function(i, element) {
      const $element = $(element);
      const computed_styles = window.getComputedStyle(element);
      const font_size = parseFloat(computed_styles.fontSize);
      Note.NORMALIZE_ATTRIBUTES.forEach(function(attribute) {
        const original_size = parseFloat(computed_styles[attribute]) || 0;
        const relative_em = original_size / font_size;
        $element.css(attribute, relative_em + "em");
      });
      const font_percentage = 100 * (font_size / parent_font_size);
      $element.css("font-size", font_percentage + "%");
      $element.attr("size", "");
      Note.normalize_sizes($element.children(), font_size);
    });
  },

  clear_timeouts: function() {
    Note.timeouts.forEach(clearTimeout);
    Note.timeouts = [];
  },

  load_all: function() {
    var fragment = document.createDocumentFragment();
    $.each($("#notes article"), function(i, article) {
      var $article = $(article);
      Note.add(
        fragment,
        $article.data("id"),
        $article.data("x"),
        $article.data("y"),
        $article.data("width"),
        $article.data("height"),
        $article.data("body"),
        $article.html()
      );
    });
    const $note_container = $(".note-container");
    $note_container.append(fragment);
    if (Note.embed) {
      Note.base_font_size = parseFloat(window.getComputedStyle($note_container[0]).fontSize);
      $.each($(".note-box"), function(i, note_box) {
        const $note_box = $(note_box);
        Note.normalize_sizes($("div.note-box-inner-border", note_box).children(), Note.base_font_size);
        // Accounting for transformation values calculations which aren't correct immediately on page load
        setTimeout(()=>{Note.Box.copy_style_attributes($note_box);}, 100);
      });
    }
    Note.Box.scale_all();
  },

  initialize_all: function() {
    if ($("#c-posts #a-show #image").length === 0 || $("video#image").length) {
      return;
    }

    Note.embed = (Utility.meta("post-has-embedded-notes") === "true");
    Note.load_all();

    this.initialize_shortcuts();
    this.initialize_highlight();
    $(document).on("hashchange.danbooru.note", this.initialize_highlight);
    Utility.keydown("up down left right", "nudge_note", Note.Box.key_nudge);
    Utility.keydown("shift+up shift+down shift+left shift+right", "resize_note", Note.Box.key_resize);
    $(window).on("resize.danbooru.note_scale", Note.Box.scale_all);
  },

  initialize_shortcuts: function() {
    $("#translate").on("click.danbooru", Note.TranslationMode.toggle);
    $("#image").on("click.danbooru", Note.Box.toggle_all);
  },

  initialize_highlight: function() {
    var matches = window.location.hash.match(/^#note-(\d+)$/);

    if (matches) {
      var $note_box = Note.Box.find(matches[1]);
      Note.Box.show_highlighted($note_box);
    }
  },
}

$(function() {
  Note.initialize_all();
});

export default Note

