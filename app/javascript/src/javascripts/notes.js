import CurrentUser from './current_user'
import Utility from './utility'

let Note = {
  HIDE_DELAY: 250,

  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");

      var opacity = 0;
      if (Note.embed) {
        opacity = 0.95
      } else {
        opacity = 0.5
      }

      $inner_border.css({
        opacity: opacity,
      });

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

    bind_events: function($note_box) {
      $note_box.on(
        "dragstart.danbooru resizestart.danbooru",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          $note_box_inner.find(".note-box-inner-border").addClass("unsaved");
          Note.dragging = true;
          Note.clear_timeouts();
          Note.Body.hide_all();
          if (Note.embed) {
            var $bg = $note_box_inner.find("div.bg")
            if ($bg.length) {
              $bg.hide();
            }
          }
          e.stopPropagation();
        }
      );

      $note_box.on("resize.danbooru",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          Note.Box.resize_inner_border($note_box_inner);
          e.stopPropagation();
        }
      );

      $note_box.on(
        "dragstop.danbooru resizestop.danbooru",
        function(e) {
          Note.dragging = false;
          if (Note.embed) {
            var $note_box_inner = $(e.currentTarget);
            var $bg = $note_box_inner.find("div.bg")
            if ($bg.length) {
              $bg.show();
              Note.Box.resize_inner_border($note_box_inner.closest(".note-box"));
            }
          }
          e.stopPropagation();
        }
      );

      $note_box.on(
        "mouseover.danbooru mouseout.danbooru",
        function(e) {
          if (Note.dragging) {
            return;
          }

          var $this = $(this);
          var $note_box_inner = $(e.currentTarget);

          if (e.type === "mouseover") {
            Note.Body.show($note_box_inner.data("id"));
            if (Note.editing) {
              $this.resizable("enable");
              $this.draggable("enable");
            }
          } else if (e.type === "mouseout") {
            Note.Body.hide($note_box_inner.data("id"));
            if (Note.editing) {
              $this.resizable("disable");
              $this.draggable("disable");
            }
          }

          e.stopPropagation();
        }
      );
    },

    find: function(id) {
      return $("#note-container div.note-box[data-id=" + id + "]");
    },

    show_highlighted: function($note_box) {
      var note_id = $note_box.data("id");

      Note.Body.show(note_id);
      $(".note-box-highlighted").removeClass("note-box-highlighted");
      $note_box.addClass("note-box-highlighted");
      $note_box[0].scrollIntoView(false);
    },

    resize_inner_border: function($note_box) {
      var $inner_border = $note_box.find("div.note-box-inner-border");
      $inner_border.css({
        height: $note_box.height() - 2,
        width: $note_box.width() - 2
      });

      if ($inner_border.width() >= $note_box.width() - 2) {
        $note_box.width($inner_border.width() + 2);
      }

      if ($inner_border.height() >= $note_box.height() - 2) {
        $note_box.height($inner_border.height() + 2);
      }

      if (Note.embed) {
        var $bg = $inner_border.find("div.bg");
        if ($bg.length) {
          $bg.height($inner_border.height());
          $bg.width($inner_border.width());
        }
      }
    },

    scale: function($note_box) {
      var $image = $("#image");
      var ratio = $image.width() / parseFloat($image.data("original-width"));
      var MIN_SIZE = 5;
      $note_box.css({
        top: Math.ceil(parseFloat($note_box.data("y")) * ratio),
        left: Math.ceil(parseFloat($note_box.data("x")) * ratio),
        width: Math.max(MIN_SIZE, Math.ceil(parseFloat($note_box.data("width")) * ratio)),
        height: Math.max(MIN_SIZE, Math.ceil(parseFloat($note_box.data("height")) * ratio))
      });
      Note.Box.resize_inner_border($note_box);
    },

    scale_all: function() {
      var container = document.getElementById('note-container');
      if (container === null) {
        return;
      }
      // Hide notes while rescaling, to prevent unnecessary reflowing
      var was_visible = container.style.display !== 'none';
      if (was_visible) {
        container.style.display = 'none';
      }
      $(".note-box").each(function(i, v) {
        Note.Box.scale($(v));
      });
      if (was_visible) {
        container.style.display = 'block';
      }
    },

    toggle_all: function() {
      var $note_container = $("#note-container");
      var is_hidden = ($note_container.css('visibility') === 'hidden');

      if (is_hidden) {
        $note_container.css('visibility', 'visible');
      } else {
        $note_container.css('visibility', 'hidden');
      }
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
      $note_body.css({
        top: $note_box.position().top + $note_box.height() + 5,
        left: $note_box.position().left
      });
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
      return $("#note-container div.note-body[data-id=" + id + "]");
    },

    hide: function(id) {
      var $note_body = Note.Body.find(id);
      Note.timeouts.push(setTimeout(() => $note_body.hide(), Note.HIDE_DELAY));
    },

    hide_all: function() {
      $("#note-container div.note-body").hide();
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
      Note.Body.display_text($note_body, text);
      if (Note.embed) {
        Note.Body.display_text($note_box.children("div.note-box-inner-border"), text);
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

      if (Note.embed) {
        $(".note-box").css("opacity", "0.5");
      }

      let $textarea = $('<textarea></textarea>');
      $textarea.css({
        width: "97%",
        height: "92%",
        resize: "none",
      });

      if ($note_body.html() !== "<em>Click to edit</em>") {
        $textarea.val($note_body.data("original-body"));
      }

      let $dialog = $('<div></div>');
      $dialog.append($textarea);
      $dialog.data("id", id);
      $dialog.dialog({
        width: 360,
        height: 210,
        position: {
          my: "right",
          at: "right-20",
          of: window
        },
        classes: {
          "ui-dialog": "note-edit-dialog",
        },
        title: "Edit note",
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
      $dialog.dialog("option", "title", 'Edit note #' + id + ' (<a href="/wiki_pages/help:notes">view help</a>)');

      $dialog.on("dialogclose.danbooru", function() {
        Note.editing = false;
        $(".note-box").resizable("enable");
        $(".note-box").draggable("enable");

        if (Note.embed) {
          $(".note-box").css("opacity", "0.95");
        }
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
          x: $note_box.position().left / ratio,
          y: $note_box.position().top / ratio,
          width: $note_box.width() / ratio,
          height: $note_box.height() / ratio,
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
        $note_box.find(".note-box-inner-border").removeClass("unsaved");
      } else {
        $note_box = Note.Box.find(data.id);
        $note_box.find(".note-box-inner-border").removeClass("unsaved");
      }
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
        Note.Box.resize_inner_border($note_box);
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
      $note_box.find(".note-box-inner-border").addClass("unsaved");
      Note.Body.set_text($note_body, $note_box, "Loading...");
      $.get("/note_previews.json", {body: text}).then(function(data) {
        Note.Body.set_text($note_body, $note_box, data.body);
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
      $("#original-file-link").click();
      $("#image").off("click", Note.Box.toggle_all);
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
      $("#image").off("mousedown", Note.TranslationMode.Drag.start);
      $(document).off("mouseup", Note.TranslationMode.Drag.stop);
      $(document.body).removeClass("mode-translation");
      $("#close-notice-link").click();
      $("#mark-as-translated-section").hide();
    },

    create_note: function(e, x, y, w, h) {
      var offset = $("#image").offset();

      if (w > 9 || h > 9) { /* minimum note size: 10px */
        if (w <= 9) {
          w = 10;
        } else if (h <= 9) {
          h = 10;
        }
        Note.create(x - offset.left, y - offset.top, w, h);
      }

      $("#note-container").css('visibility', 'visible');
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
            Note.TranslationMode.Drag.x = Note.TranslationMode.Drag.dragStartX;
            Note.TranslationMode.Drag.w = Note.TranslationMode.Drag.dragDistanceX;
          } else {
            Note.TranslationMode.Drag.x = Note.TranslationMode.Drag.dragStartX + Note.TranslationMode.Drag.dragDistanceX;
            Note.TranslationMode.Drag.w = -Note.TranslationMode.Drag.dragDistanceX;
          }

          if (Note.TranslationMode.Drag.dragDistanceY >= 0) {
            Note.TranslationMode.Drag.y = Note.TranslationMode.Drag.dragStartY;
            Note.TranslationMode.Drag.h = Note.TranslationMode.Drag.dragDistanceY;
          } else {
            Note.TranslationMode.Drag.y = Note.TranslationMode.Drag.dragStartY + Note.TranslationMode.Drag.dragDistanceY;
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
        $(document).off("mousemove", Note.TranslationMode.Drag.drag);

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
    Note.Body.display_text($note_body, sanitized_body);
    if (Note.embed) {
      Note.Body.display_text($note_box.children("div.note-box-inner-border"), sanitized_body);
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
    $note_box.find(".note-box-inner-border").addClass("unsaved");
    $note_body.html("<em>Click to edit</em>");
    $("#note-container").append($note_box);
    $("#note-container").append($note_body);
    Note.Box.resize_inner_border($note_box);
    Note.id += "x";
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
    $("#note-container").append(fragment);
    if (Note.embed) {
      $.each($(".note-box"), function(i, note_box) {
        Note.Box.resize_inner_border($(note_box));
      });
    }
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

