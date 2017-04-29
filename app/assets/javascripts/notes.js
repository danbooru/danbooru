Danbooru.Note = {
  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");

      var opacity = 0;
      if (Danbooru.Note.embed) {
        opacity = 0.95
      } else {
        opacity = 0.5
      }

      $inner_border.css({
        opacity: opacity,
      });

      var $note_box = $('<div/>');
      $note_box.addClass("note-box");

      if (Danbooru.Note.embed) {
        $note_box.addClass("embedded");
      }

      $note_box.data("id", String(id));
      $note_box.attr("data-id", String(id));
      $note_box.draggable({
        containment: $("#image"),
        stop: function(e, ui) {
          Danbooru.Note.Box.update_data_attributes($note_box);
        }
      });
      $note_box.resizable({
        containment: $("#image"),
        handles: "se, nw",
        stop: function(e, ui) {
          Danbooru.Note.Box.update_data_attributes($note_box);
        }
      });
      $note_box.css({position: "absolute"});
      $note_box.append($inner_border);
      Danbooru.Note.Box.bind_events($note_box);

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
        "dragstart resizestart",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          $note_box_inner.find(".note-box-inner-border").addClass("unsaved");
          Danbooru.Note.dragging = true;
          Danbooru.Note.clear_timeouts();
          Danbooru.Note.Body.hide_all();
          if (Danbooru.Note.embed) {
            var $bg = $note_box_inner.find("div.bg")
            if ($bg.length) {
              $bg.hide();
            }
          }
          e.stopPropagation();
        }
      );

      $note_box.resize(
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          Danbooru.Note.Box.resize_inner_border($note_box_inner);
          e.stopPropagation();
        }
      );

      $note_box.on(
        "dragstop resizestop",
        function(e) {
          Danbooru.Note.dragging = false;
          if (Danbooru.Note.embed) {
            var $note_box_inner = $(e.currentTarget);
            var $bg = $note_box_inner.find("div.bg")
            if ($bg.length) {
              $bg.show();
              Danbooru.Note.Box.resize_inner_border($note_box_inner.closest(".note-box"));
            }
          }
          e.stopPropagation();
        }
      );

      $note_box.on(
        "mouseover mouseout",
        function(e) {
          if (Danbooru.Note.dragging) {
            return;
          }

          var $note_box_inner = $(e.currentTarget);
          if (e.type === "mouseover") {
            Danbooru.Note.Body.show($note_box_inner.data("id"));
            if (Danbooru.Note.editing) {
              var $this = $(this);
              $this.resizable("enable");
              $this.draggable("enable");
            }
          } else if (e.type === "mouseout") {
            Danbooru.Note.Body.hide($note_box_inner.data("id"));
            if (Danbooru.Note.editing) {
              var $this = $(this);
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

      if (Danbooru.Note.embed) {
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
      Danbooru.Note.Box.resize_inner_border($note_box);
    },

    scale_all: function() {
      var container = document.getElementById('note-container');
      if (container === null) {
        return;
      }
      // Hide notes while rescaling, to prevent unnecessary reflowing
      var was_visible = container.style.display != 'none';
      if (was_visible) {
        container.style.display = 'none';
      }
      $(".note-box").each(function(i, v) {
        Danbooru.Note.Box.scale($(v));
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
      Danbooru.Note.Body.bind_events($note_body);
      return $note_body;
    },

    initialize: function($note_body) {
      var $note_box = Danbooru.Note.Box.find($note_body.data("id"));
      $note_body.css({
        top: $note_box.position().top + $note_box.height() + 5,
        left: $note_box.position().left
      });
      Danbooru.Note.Body.bound_position($note_body);
    },

    bound_position: function($note_body) {
      var $image = $("#image");
      var doc_width = $image.offset().left + $image.width();

      /*while ($note_body[0].clientHeight < $note_body[0].scrollHeight) {
        $note_body.css({height: $note_body.height() + 5});
      }

      while ($note_body[0].clientWidth < $note_body[0].scrollWidth) {
        $note_body.css({width: $note_body.width() + 5});
      }*/

      if ($note_body.offset().left + $note_body.width() > doc_width) {
        $note_body.css({
          left: $note_body.position().left - 10 - ($note_body.offset().left + $note_body.width() - doc_width)
        });
      }
    },

    show: function(id) {
      Danbooru.Note.Body.hide_all();
      Danbooru.Note.clear_timeouts();
      var $note_body = Danbooru.Note.Body.find(id);
      if (!$note_body.data('resized')) {
        Danbooru.Note.Body.resize($note_body);
        $note_body.data('resized', 'true');
      }
      $note_body.show();
      Danbooru.Note.Body.initialize($note_body);
    },

    find: function(id) {
      return $("#note-container div.note-body[data-id=" + id + "]");
    },

    hide: function(id) {
      var $note_body = Danbooru.Note.Body.find(id);
      Danbooru.Note.timeouts.push($.timeout(250).done(function() {$note_body.hide();}));
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

      if ((w / h) < golden_ratio) {
        var lo = 140;
        var hi = 400;
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
        var lo = 20;
        var hi = w;

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
      Danbooru.Note.Body.display_text($note_body, text);
      if (Danbooru.Note.embed) {
        Danbooru.Note.Body.display_text($note_box.children("div.note-box-inner-border"), text);
      }
      Danbooru.Note.Body.resize($note_body);
      Danbooru.Note.Body.bound_position($note_body);
    },

    display_text: function($note_body, text) {
      text = text.replace(/<tn>/g, '<p class="tn">');
      text = text.replace(/<\/tn>/g, '</p>');
      text = text.replace(/\n/g, '<br>');
      $note_body.html(text);
    },

    bind_events: function($note_body) {
      $note_body.mouseover(function(e) {
        var $note_body_inner = $(e.currentTarget);
        Danbooru.Note.Body.show($note_body_inner.data("id"));
        e.stopPropagation();
      });

      $note_body.mouseout(function(e) {
        var $note_body_inner = $(e.currentTarget);
        Danbooru.Note.Body.hide($note_body_inner.data("id"));
        e.stopPropagation();
      });

      if (Danbooru.meta("current-user-name") !== "Anonymous") {
        $note_body.click(function(e) {
          if (e.target.tagName !== "A") {
            var $note_body_inner = $(e.currentTarget);
            Danbooru.Note.Edit.show($note_body_inner);
          }
          e.stopPropagation();
        });
      } else {
        $note_body.click(function(e) {
          if (e.target.tagName !== "A") {
            Danbooru.notice("You must be logged in to edit notes");
          }
          e.stopPropagation();
        });
      }
    }
  },

  Edit: {
    show: function($note_body) {
      if (Danbooru.Note.editing) {
        return;
      }

      $(".note-box").resizable("disable");
      $(".note-box").draggable("disable");

      if (Danbooru.Note.embed) {
        $(".note-box").css("opacity", "0.5");
      }

      $textarea = $('<textarea></textarea>');
      $textarea.css({
        width: "97%",
        height: "92%",
        resize: "none",
      });

      if ($note_body.html() !== "<em>Click to edit</em>") {
        $textarea.val($note_body.data("original-body"));
      }

      $dialog = $('<div></div>');
      $dialog.append($textarea);
      $dialog.data("id", $note_body.data("id"));
      $dialog.dialog({
        width: 360,
        height: 210,
        position: {
          my: "right",
          at: "right-20",
          of: window
        },
        dialogClass: "note-edit-dialog",
        title: "Edit note",
        buttons: {
          "Save": Danbooru.Note.Edit.save,
          "Preview": Danbooru.Note.Edit.preview,
          "Cancel": Danbooru.Note.Edit.cancel,
          "Delete": Danbooru.Note.Edit.destroy,
          "History": Danbooru.Note.Edit.history
        }
      });
      $dialog.data("uiDialog")._title = function(title) {
        title.html(this.options.title); // Allow unescaped html in dialog title
      }
      $dialog.dialog("option", "title", 'Edit note (<a href="/wiki_pages/help:notes">view help</a>)');

      $dialog.on("dialogclose", function() {
        Danbooru.Note.editing = false;
        $(".note-box").resizable("enable");
        $(".note-box").draggable("enable");

        if (Danbooru.Note.embed) {
          $(".note-box").css("opacity", "0.95");
        }
      });

      $textarea.selectEnd();
      Danbooru.Note.editing = true;
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
          post_id: Danbooru.meta("post-id")
        }
      }

      if ($note_box.data("id").match(/x/)) {
        hash.note.html_id = $note_box.data("id");
      }

      return hash;
    },

    error_handler: function(xhr, status, exception) {
      Danbooru.error("Error: " + xhr.responseJSON.reasons.join("; "));
    },

    success_handler: function(data, status, xhr) {
      if (data.html_id) { // new note
        var $note_body = Danbooru.Note.Body.find(data.html_id);
        var $note_box = Danbooru.Note.Box.find(data.html_id);
        $note_body.data("id", String(data.id)).attr("data-id", data.id);
        $note_box.data("id", String(data.id)).attr("data-id", data.id);
        $note_box.find(".note-box-inner-border").removeClass("unsaved");
      } else {
        var $note_box = Danbooru.Note.Box.find(data.id);
        $note_box.find(".note-box-inner-border").removeClass("unsaved");
      }
    },

    save: function() {
      var $this = $(this);
      var $textarea = $this.find("textarea");
      var id = $this.data("id");
      var $note_body = Danbooru.Note.Body.find(id);
      var $note_box = Danbooru.Note.Box.find(id);
      var text = $textarea.val();
      $note_body.data("original-body", text);
      Danbooru.Note.Body.set_text($note_body, $note_box, "Loading...");
      $.get("/note_previews.json", {body: text}).success(function(data) {
        Danbooru.Note.Body.set_text($note_body, $note_box, data.body);
        Danbooru.Note.Box.resize_inner_border($note_box);
        $note_body.show();
      });
      $this.dialog("close");

      if (id.match(/\d/)) {
        $.ajax("/notes/" + id + ".json", {
          type: "PUT",
          data: Danbooru.Note.Edit.parameterize_note($note_box, $note_body),
          error: Danbooru.Note.Edit.error_handler,
          success: Danbooru.Note.Edit.success_handler
        });
      } else {
        $.ajax("/notes.json", {
          type: "POST",
          data: Danbooru.Note.Edit.parameterize_note($note_box, $note_body),
          error: Danbooru.Note.Edit.error_handler,
          success: Danbooru.Note.Edit.success_handler
        });
      }
    },

    preview: function() {
      var $this = $(this);
      var $textarea = $this.find("textarea");
      var id = $this.data("id");
      var $note_body = Danbooru.Note.Body.find(id);
      var text = $textarea.val();
      var $note_box = Danbooru.Note.Box.find(id);
      $note_box.find(".note-box-inner-border").addClass("unsaved");
      Danbooru.Note.Body.set_text($note_body, $note_box, "Loading...");
      $.get("/note_previews.json", {body: text}).success(function(data) {
        Danbooru.Note.Body.set_text($note_body, $note_box, data.body);
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
            Danbooru.Note.Box.find(id).remove();
            Danbooru.Note.Body.find(id).remove();
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
      if (Danbooru.Note.TranslationMode.active) {
        Danbooru.Note.TranslationMode.stop(e);
      } else {
        Danbooru.Note.TranslationMode.start(e);
      }
    },

    start: function(e) {
      e.preventDefault();

      if (Danbooru.meta("current-user-id") == "") {
        Danbooru.notice("You must be logged in to edit notes");
        return;
      }

      if (Danbooru.Note.TranslationMode.active) {
        return;
      }

      $("#image").css("cursor", "crosshair");
      Danbooru.Note.TranslationMode.active = true;
      $(document.body).addClass("mode-translation");
      $("#original-file-link").click();
      $("#image").off("click", Danbooru.Note.Box.toggle_all);
      $("#image").mousedown(Danbooru.Note.TranslationMode.Drag.start);
      $(window).mouseup(Danbooru.Note.TranslationMode.Drag.stop);
      $("#mark-as-translated-section").show();

      Danbooru.notice('Translation mode is on. Drag on the image to create notes. <a href="#">Turn translation mode off</a> (shortcut is <span class="key">n</span>).');
      $("#notice a:contains(Turn translation mode off)").click(Danbooru.Note.TranslationMode.stop);
    },

    stop: function(e) {
      e.preventDefault();

      Danbooru.Note.TranslationMode.active = false;
      $("#image").css("cursor", "auto");
      $("#image").click(Danbooru.Note.Box.toggle_all);
      $("#image").off("mousedown", Danbooru.Note.TranslationMode.Drag.start);
      $(window).off("mouseup", Danbooru.Note.TranslationMode.Drag.stop);
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
        Danbooru.Note.create(x - offset.left, y - offset.top, w, h);
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
        $(window).mousemove(Danbooru.Note.TranslationMode.Drag.drag);
        Danbooru.Note.TranslationMode.Drag.dragStartX = e.pageX;
        Danbooru.Note.TranslationMode.Drag.dragStartY = e.pageY;
      },

      drag: function (e) {
        Danbooru.Note.TranslationMode.Drag.dragDistanceX = e.pageX - Danbooru.Note.TranslationMode.Drag.dragStartX;
        Danbooru.Note.TranslationMode.Drag.dragDistanceY = e.pageY - Danbooru.Note.TranslationMode.Drag.dragStartY;
        var $image = $("#image");
        var offset = $image.offset();
        var limitX1 = $image.width() - Danbooru.Note.TranslationMode.Drag.dragStartX + offset.left - 1;
        var limitX2 = offset.left - Danbooru.Note.TranslationMode.Drag.dragStartX;
        var limitY1 = $image.height()- Danbooru.Note.TranslationMode.Drag.dragStartY + offset.top - 1;
        var limitY2 = offset.top - Danbooru.Note.TranslationMode.Drag.dragStartY;

        if (Danbooru.Note.TranslationMode.Drag.dragDistanceX > limitX1) {
          Danbooru.Note.TranslationMode.Drag.dragDistanceX = limitX1;
        } else if (Danbooru.Note.TranslationMode.Drag.dragDistanceX < limitX2) {
          Danbooru.Note.TranslationMode.Drag.dragDistanceX = limitX2;
        }

        if (Danbooru.Note.TranslationMode.Drag.dragDistanceY > limitY1) {
          Danbooru.Note.TranslationMode.Drag.dragDistanceY = limitY1;
        } else if (Danbooru.Note.TranslationMode.Drag.dragDistanceY < limitY2) {
          Danbooru.Note.TranslationMode.Drag.dragDistanceY = limitY2;
        }

        if (Math.abs(Danbooru.Note.TranslationMode.Drag.dragDistanceX) > 9 && Math.abs(Danbooru.Note.TranslationMode.Drag.dragDistanceY) > 9) {
          Danbooru.Note.TranslationMode.Drag.dragging = true; /* must drag at least 10pixels (minimum note size) in both dimensions. */
        }
        if (Danbooru.Note.TranslationMode.Drag.dragging) {
          if (Danbooru.Note.TranslationMode.Drag.dragDistanceX >= 0) {
            Danbooru.Note.TranslationMode.Drag.x = Danbooru.Note.TranslationMode.Drag.dragStartX;
            Danbooru.Note.TranslationMode.Drag.w = Danbooru.Note.TranslationMode.Drag.dragDistanceX;
          } else {
            Danbooru.Note.TranslationMode.Drag.x = Danbooru.Note.TranslationMode.Drag.dragStartX + Danbooru.Note.TranslationMode.Drag.dragDistanceX;
            Danbooru.Note.TranslationMode.Drag.w = -Danbooru.Note.TranslationMode.Drag.dragDistanceX;
          }

          if (Danbooru.Note.TranslationMode.Drag.dragDistanceY >= 0) {
            Danbooru.Note.TranslationMode.Drag.y = Danbooru.Note.TranslationMode.Drag.dragStartY;
            Danbooru.Note.TranslationMode.Drag.h = Danbooru.Note.TranslationMode.Drag.dragDistanceY;
          } else {
            Danbooru.Note.TranslationMode.Drag.y = Danbooru.Note.TranslationMode.Drag.dragStartY + Danbooru.Note.TranslationMode.Drag.dragDistanceY;
            Danbooru.Note.TranslationMode.Drag.h = -Danbooru.Note.TranslationMode.Drag.dragDistanceY;
          }

          $('#note-preview').css({
            display: 'block',
            left: (Danbooru.Note.TranslationMode.Drag.x + 1),
            top: (Danbooru.Note.TranslationMode.Drag.y + 1),
            width: (Danbooru.Note.TranslationMode.Drag.w - 3),
            height: (Danbooru.Note.TranslationMode.Drag.h - 3)
          });
        }
      },

      stop: function (e) {
        if (e.which !== 1) {
          return;
        }
        if (Danbooru.Note.TranslationMode.Drag.dragStartX === 0) {
          return; /* 'stop' is bound to window, don't create note if start wasn't triggered */
        }
        $(window).off("mousemove");

        if (Danbooru.Note.TranslationMode.Drag.dragging) {
          $('#note-preview').css({display:'none'});
          Danbooru.Note.TranslationMode.create_note(e, Danbooru.Note.TranslationMode.Drag.x, Danbooru.Note.TranslationMode.Drag.y, Danbooru.Note.TranslationMode.Drag.w-1, Danbooru.Note.TranslationMode.Drag.h-1);
          Danbooru.Note.TranslationMode.Drag.dragging = false; /* border of the note is pixel-perfect on the preview border */
        } else { /* no dragging -> toggle display of notes */
          Danbooru.Note.Box.toggle_all();
        }

        Danbooru.Note.TranslationMode.Drag.dragStartX = 0;
        Danbooru.Note.TranslationMode.Drag.dragStartY = 0;
      }
    }
  },

  id: "x",
  dragging: false,
  editing: false,
  timeouts: [],
  pending: {},

  add: function(container, id, x, y, w, h, original_body, sanitized_body) {
    var $note_box = Danbooru.Note.Box.create(id);
    var $note_body = Danbooru.Note.Body.create(id);

    $note_box.data('x', x);
    $note_box.data('y', y);
    $note_box.data('width', w);
    $note_box.data('height', h);
    container.appendChild($note_box[0]);
    container.appendChild($note_body[0]);
    $note_body.data("original-body", original_body);
    Danbooru.Note.Box.scale($note_box);
    Danbooru.Note.Body.display_text($note_body, sanitized_body);
    if (Danbooru.Note.embed) {
      Danbooru.Note.Body.display_text($note_box.children("div.note-box-inner-border"), sanitized_body);
    }
  },

  create: function(x, y, w, h) {
    var $note_box = Danbooru.Note.Box.create(Danbooru.Note.id);
    var $note_body = Danbooru.Note.Body.create(Danbooru.Note.id);
    $note_box.css({
      top: y,
      left: x,
      width: w,
      height: h
    });
    Danbooru.Note.Box.update_data_attributes($note_box);
    $note_box.find(".note-box-inner-border").addClass("unsaved");
    $note_body.html("<em>Click to edit</em>");
    $("#note-container").append($note_box);
    $("#note-container").append($note_body);
    Danbooru.Note.Box.resize_inner_border($note_box);
    Danbooru.Note.id += "x";
  },

  clear_timeouts: function() {
    $.each(Danbooru.Note.timeouts, function(i, v) {
      v.clear();
    });

    Danbooru.Note.timeouts = [];
  },

  load_all: function() {
    var fragment = document.createDocumentFragment();
    $.each($("#notes article"), function(i, article) {
      var $article = $(article);
      Danbooru.Note.add(
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
    if (Danbooru.Note.embed) {
      $.each($(".note-box"), function(i, note_box) {
        Danbooru.Note.Box.resize_inner_border($(note_box));
      });
    }
  }
}

$(function() {
  if ($("#c-posts").length && $("#a-show").length && $("#image").length && !$("video#image").length) {
    if ($("#note-locked-notice").length == 0) {
      $("#translate").click(Danbooru.Note.TranslationMode.toggle);
      Danbooru.keydown("n", "translation_mode", Danbooru.Note.TranslationMode.toggle);
    }
    Danbooru.Note.embed = (Danbooru.meta("post-has-embedded-notes") === "true");
    Danbooru.Note.load_all();
    $("#image").click(Danbooru.Note.Box.toggle_all);
  }
});
