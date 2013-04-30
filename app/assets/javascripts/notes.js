Danbooru.Note = {
  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");

      $inner_border.css({
        opacity: 0.5,
        "-ms-filter": "progid:DXImageTransform.Microsoft.Alpha(Opacity=50)",
        "filter": "alpha(opacity=50)",
        zoom: 1
      });

      var $note_box = $('<div/>');
      $note_box.addClass("note-box");
      $note_box.data("id", String(id));
      $note_box.attr("data-id", String(id));
      $note_box.draggable({containment: $("#image")});
      $note_box.resizable({
        containment: $("#image"),
        handles: "se"
      });
      $note_box.css({position: "absolute"});
      $note_box.append($inner_border);
      Danbooru.Note.Box.bind_events($note_box);

      return $note_box;
    },

    bind_events: function($note_box) {
      $note_box.bind(
        "dragstart resizestart",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          Danbooru.Note.dragging = true;
          Danbooru.Note.clear_timeouts();
          Danbooru.Note.Body.hide_all();
          e.stopPropagation();
        }
      )

      $note_box.bind(
        "resize",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          Danbooru.Note.Box.resize_inner_border($note_box_inner);
          e.stopPropagation();
        }
      );

      $note_box.bind(
        "dragstop resizestop",
        function(e) {
          Danbooru.Note.dragging = false;
          e.stopPropagation();
        }
      );

      $note_box.bind(
        "mouseover mouseout",
        function(e) {
          if (Danbooru.Note.dragging) {
            return;
          }

          var $note_box_inner = $(e.currentTarget);
          if (e.type === "mouseover") {
            Danbooru.Note.Body.show($note_box_inner.data("id"));
          } else if (e.type === "mouseout") {
            Danbooru.Note.Body.hide($note_box_inner.data("id"));
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
    },

    scale: function($note_box) {
      var $image = $("#image");
      var ratio = $image.width() / parseFloat($("#image").data("original-width"));
      var $note = $("#notes > article[data-id=" + $note_box.data("id") + "]");
      $note_box.css({
        top: Math.ceil(parseFloat($note.data("y")) * ratio),
        left: Math.ceil(parseFloat($note.data("x")) * ratio),
        width: Math.ceil(parseFloat($note.data("width")) * ratio),
        height: Math.ceil(parseFloat($note.data("height")) * ratio)
      });
      Danbooru.Note.Box.resize_inner_border($note_box);
    },

    scale_all: function() {
      $(".note-box").each(function(i, v) {
        Danbooru.Note.Box.scale($(v));
      });
    },

    toggle_all: function() {
      $(".note-box").toggle();
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

      while ($note_body[0].clientHeight < $note_body[0].scrollHeight) {
        $note_body.css({height: $note_body.height() + 5});
      }

      while ($note_body[0].clientWidth < $note_body[0].scrollWidth) {
        $note_body.css({width: $note_body.width() + 5});
      }

      if ($note_body.offset().left + $note_body.width() > doc_width) {
        $note_body.css({
          left: $note_body.position().left - 10 - ($note_body.offset().left + $note_body.width() - doc_width)
        });
      }
    },

    show: function(id) {
      if (Danbooru.Note.editing) {
        return;
      }

      Danbooru.Note.Body.hide_all();
      Danbooru.Note.clear_timeouts();
      var $note_body = Danbooru.Note.Body.find(id);
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
        } while ((hi - lo) > 4)
        if ($note_body.height() > h) {
          $note_body.css("minWidth", hi);
        }
      }
    },

    set_text: function($note_body, text) {
      Danbooru.Note.Body.display_text($note_body, text);
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
          var $note_body_inner = $(e.currentTarget);
          Danbooru.Note.Edit.show($note_body_inner);
          e.stopPropagation();
        })
      } else {
        $note_body.click(function(e) {
          Danbooru.notice("You must be logged in to edit notes");
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

      $textarea = $('<textarea></textarea>');
      $textarea.css({
        width: "95%",
        height: "10em"
      });

      if ($note_body.html() !== "<em>Click to edit</em>") {
        $textarea.val($note_body.data("original-body"));
      }

      $dialog = $('<div></div>');
      $dialog.append($textarea);
      $dialog.data("id", $note_body.data("id"));
      $dialog.dialog({
        width: 350,
        dialogClass: "note-edit-dialog",
        title: "Edit note",
        buttons: {
          "Save": Danbooru.Note.Edit.save,
          "Cancel": Danbooru.Note.Edit.cancel,
          "Delete": Danbooru.Note.Edit.delete,
          "History": Danbooru.Note.Edit.history
        }
      });
      $dialog.bind("dialogclose", function() {
        Danbooru.Note.editing = false;
        $(".note-box").resizable("enable");
        $(".note-box").draggable("enable");
      });
      // Danbooru.Note.editing = true;
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
      Danbooru.error("There was an error saving the note");
    },

    success_handler: function(data, status, xhr) {
      if (data.html_id) {
        var $note_body = Danbooru.Note.Body.find(data.html_id);
        var $note_box = Danbooru.Note.Box.find(data.html_id);
        $note_body.data("id", String(data.id)).attr("data-id", data.id);
        $note_box.data("id", String(data.id)).attr("data-id", data.id);
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
      Danbooru.Note.Body.set_text($note_body, text);
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

    cancel: function() {
      $(this).dialog("close");
    },

    delete: function() {
      if (!confirm("Do you really want to delete this note?")) {
        return
      }

      var $this = $(this);
      var id = $this.data("id");
      Danbooru.Note.Box.find(id).remove();
      Danbooru.Note.Body.find(id).remove();
      $(this).dialog("close");

      if (id.match(/\d/)) {
        $.ajax("/notes/" + id + ".js", {
          type: "DELETE"
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

    start: function(e) {
      e.preventDefault();

      if (Danbooru.Note.TranslationMode.active) {
        return;
      }

      Danbooru.Note.TranslationMode.active = true;
      $("#original-file-link").click();
      $("#image").one("click", function() { $(".note-box").show() }); /* override the 'hide all note boxes' click event */
      $("#image").one("mousedown", Danbooru.Note.TranslationMode.Drag.start).one("mouseup", Danbooru.Note.TranslationMode.Drag.stop);
      Danbooru.notice('Click or drag on the image to create a note (shortcut is <span class="key">n</span>)');
    },

    stop: function() {
      Danbooru.Note.TranslationMode.active = false;
    },

    create_note: function(e,dragged,x,y,w,h) {
      Danbooru.Note.TranslationMode.active = false;
      var offset = $("#image").offset();
      
      if(dragged) {
        if(w > 9 && h > 9) { /* minimum note size: 10px */
          Danbooru.Note.new(x-offset.left,y-offset.top,w,h);
        }
      } else {
        Danbooru.Note.new(e.pageX - offset.left, e.pageY - offset.top);
      }
      Danbooru.Note.TranslationMode.stop();
      $(".note-box").show();
      e.stopPropagation();
      e.preventDefault();
    },
    
    Drag: {
      dragging: false,
      dragStartX: 0,
      dragStartY: 0,
      dragDistanceY: 0,
      dragDistanceY: 0,
      
      start: function (e) {
        e.preventDefault(); /* don't drag the image */
        $(window).mousemove(Danbooru.Note.TranslationMode.Drag.drag);
        Danbooru.Note.TranslationMode.Drag.dragStartX = e.pageX;
        Danbooru.Note.TranslationMode.Drag.dragStartY = e.pageY;
      },
      
      drag: function (e) {
        Danbooru.Note.TranslationMode.Drag.dragDistanceX = e.pageX - Danbooru.Note.TranslationMode.Drag.dragStartX;
        Danbooru.Note.TranslationMode.Drag.dragDistanceY = e.pageY - Danbooru.Note.TranslationMode.Drag.dragStartY;
        
        if(Danbooru.Note.TranslationMode.Drag.dragDistanceX > 9 && Danbooru.Note.TranslationMode.Drag.dragDistanceY > 9) {
          Danbooru.Note.TranslationMode.Drag.dragging = true; /* must drag at least 10pixels (minimum note size) in both dimensions. */
        }
        if(Danbooru.Note.TranslationMode.Drag.dragging) {
          var offset = $("#image").offset();
          $('#note-helper').css({ /* preview of the note you are dragging */
            display: 'block',
            left: (Danbooru.Note.TranslationMode.Drag.dragStartX - offset.left + 1),
            top: (Danbooru.Note.TranslationMode.Drag.dragStartY - offset.top + 1),
            width: (Danbooru.Note.TranslationMode.Drag.dragDistanceX - 3),
            height: (Danbooru.Note.TranslationMode.Drag.dragDistanceY - 3)
          });
        }
      },
      
      stop: function (e) {
        $(window).unbind("mousemove");
        if(Danbooru.Note.TranslationMode.Drag.dragging) {
          $('#note-helper').css({display:'none'});
          Danbooru.Note.TranslationMode.create_note(e, true, Danbooru.Note.TranslationMode.Drag.dragStartX, Danbooru.Note.TranslationMode.Drag.dragStartY, Danbooru.Note.TranslationMode.Drag.dragDistanceX-1, Danbooru.Note.TranslationMode.Drag.dragDistanceY-1);
          Danbooru.Note.TranslationMode.Drag.dragging = false; /* border of the note is pixel-perfect on the preview border */
        } else { /* no dragging -> create a normal note */
          Danbooru.Note.TranslationMode.create_note(e);
        }
      }
    }
  },

  id: "x",
  dragging: false,
  editing: false,
  timeouts: [],
  pending: {},

  add: function(id, x, y, w, h, text) {
    var $note_box = Danbooru.Note.Box.create(id);
    var $note_body = Danbooru.Note.Body.create(id);

    $note_box.css({
      left: x,
      top: y,
      width: w,
      height: h,
      display: 'none'
    });

    $("#note-container").append($note_box);
    $("#note-container").append($note_body);
    $note_body.data("original-body", text);
    Danbooru.Note.Box.scale($note_box);
    Danbooru.Note.Body.set_text($note_body, text);
  },

  new: function(x, y) {
    var $note_box = Danbooru.Note.Box.create(Danbooru.Note.id);
    var $note_body = Danbooru.Note.Body.create(Danbooru.Note.id);
    $note_box.css({
      top: y,
      left: x
    });
    $note_box.find(".note-box-inner-border").addClass("unsaved");
    $note_body.html("<em>Click to edit</em>");
    $("#note-container").append($note_box);
    $("#note-container").append($note_body);
    Danbooru.Note.Body.resize($note_body);
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
    $.each($("#notes article"), function(i, article) {
      var $article = $(article);
      Danbooru.Note.add(
        $article.data("id"),
        $article.data("x"),
        $article.data("y"),
        $article.data("width"),
        $article.data("height"),
        $article.html()
      );
    });
    
    $('#note-container').css('display','none');
    $('.note-box').each(function(i, v) {
      $(v).css('display','block')
    });
    $('#note-container').css('display','block');
  }
}

$(function() {
  if ($("#c-posts").length && $("#a-show").length && $("#image").length) {
    if ($("#note-locked-notice").length == 0) {
      $("#translate").bind("click", Danbooru.Note.TranslationMode.start);
      $(document).bind("keydown.n", Danbooru.Note.TranslationMode.start);
    }
    Danbooru.Note.load_all();
    $("#image").click(Danbooru.Note.Box.toggle_all);
  }
});
