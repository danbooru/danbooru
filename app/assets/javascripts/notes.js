Danbooru.Note = {
  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");
      $inner_border.css({opacity: 0.5});

      var $note_box = $('<div/>');
      $note_box.addClass("note-box");
      $note_box.data("id", String(id));
      $note_box.attr("data-id", String(id));
      $note_box.draggable({containment: "parent"});
      $note_box.resizable({
        containment: "parent", 
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
        }
      )
      
      $note_box.bind(
        "resize",
        function(e) {
          var $note_box_inner = $(e.currentTarget);
          Danbooru.Note.Box.resize_inner_border($note_box_inner);
        }
      );

      $note_box.bind(
        "dragstop resizestop",
        function(e) {
          Danbooru.Note.dragging = false;
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
      var original_width = parseFloat($image.data("original-width"));
      var ratio = $image.width() / original_width;
      
      if (ratio < 1) {
        var scaled_width = Math.round($note_box.width() * ratio);
        var scaled_height = Math.round($note_box.height() * ratio);
        var scaled_top = Math.round($note_box.position().top * ratio);
        var scaled_left = Math.round($note_box.position().left * ratio);
        $note_box.css({
          top: scaled_top,
          left: scaled_left,
          width: scaled_width,
          height: scaled_height
        });
        Danbooru.Note.Box.resize_inner_border($note_box);
      }
    },
    
    scale_all: function() {
      $(".note-box").each(function(i, v) {
        Danbooru.Note.Box.scale($(v));
      });
    },
    
    descale: function($note_box) {
      var $image = $("#image");
      var original_width = parseFloat($image.data("original-width"));
      var ratio = original_width / $image.width();
      
      if (ratio > 1) {
        var scaled_width = Math.round($note_box.width() * ratio);
        var scaled_height = Math.round($note_box.height() * ratio);
        var scaled_top = Math.round($note_box.position().top * ratio);
        var scaled_left = Math.round($note_box.position().left * ratio);
        $note_box.css({
          top: scaled_top,
          left: scaled_left,
          width: scaled_width,
          height: scaled_height
        });
        Danbooru.Note.Box.resize_inner_border($note_box);
      }
    },
    
    descale_all: function() {
      $(".note-box").each(function(i, v) {
        Danbooru.Note.Box.descale($(v));
      });
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
      var doc_width = $(window).width();
      if ($note_body.offset().left + $note_body.width() > doc_width) {
        $note_body.css({
          // 30 is a magic number to factor in width of the scroll bar
          left: $note_body.position().left - 30 - ($note_body.offset().left + $note_body.width() - doc_width)
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
      return;
      
      var w = $note_body.width();
      var h = $note_body.height();
      var golden_ratio = 1.6180339887;

      while (w / h < golden_ratio) {
        w = w * 1.025;
        h = h / 1.025;
      }
      
      while (w / h > golden_ratio) {
        w = w / 1.025;
        h = h * 1.025;
      }

      $note_body.css({
        width: w,
        height: "auto"
      });
    },
    
    set_text: function($note_body, text) {
      text = text.replace('<tn>', '<p class="tn">');
      text = text.replace('</tn>', '</p>');
      $note_body.html(text);
      Danbooru.Note.Body.resize($note_body);
      Danbooru.Note.Body.bound_position($note_body);
    },
    
    bind_events: function($note_body) {
      $note_body.mouseover(function(e) {
        var $note_body_inner = $(e.currentTarget);
        Danbooru.Note.Body.show($note_body_inner.data("id"));
      });

      $note_body.mouseout(function(e) {
        var $note_body_inner = $(e.currentTarget);
        Danbooru.Note.Body.hide($note_body_inner.data("id"));
      });

      if (Danbooru.meta("current-user-name") !== "Anonymous") {
        $note_body.click(function(e) {
          var $note_body_inner = $(e.currentTarget);
          Danbooru.Note.Edit.show($note_body_inner);
        })
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
        width: "100%",
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
          body: $note_body.html(),
          post_id: Danbooru.meta("post-id")
        }
      }
      
      if ($note_box.data("id").match(/x/)) {
        hash.note.html_id = $note_box.data("id");
      }
      
      return hash;
    },
    
    error_handler: function(xhr, status, exception) {
      Danbooru.j_error("There was an error saving the note");
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
        window.location.href = "/note_versions?search[note_id_eq]=" + id;
      }
      $(this).dialog("close");
    }
  },
  
  TranslationMode: {
    start: function() {
      $("#original-file-link").click();
      $("#note-container").click(Danbooru.Note.TranslationMode.create_note);
      $("#translate").one("click", Danbooru.Note.TranslationMode.stop).html("Click on image");
    },
    
    stop: function() {
      $("#note-container").unbind("click");
      $("#translate").one("click", Danbooru.Note.TranslationMode.start).html("Translate");
    },
    
    create_note: function(e) {
      var offset = $("#image").offset();
      Danbooru.Note.new(e.pageX - offset.left, e.pageY - offset.top);
      Danbooru.Note.TranslationMode.stop();
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
      height: h
    });
    
    $("div#note-container").append($note_box);
    $("div#note-container").append($note_body);
    $note_body.data("original-body", text);
    Danbooru.Note.Box.scale($note_box);
    Danbooru.Note.Box.resize_inner_border($note_box);
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
    $("div#note-container").append($note_box);
    $("div#note-container").append($note_body);
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
    $.each($("section#notes article"), function(i, article) {
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
  }
}

$(function() {
  if ($("#c-posts #a-show").size() > 0) {
    $("#translate").one("click", Danbooru.Note.TranslationMode.start);
    $("#note-container").width($("#image").width()).height($("#image").height());
    $(document).bind("keydown", "ctrl+n", Danbooru.Note.TranslationMode.start);
    Danbooru.Note.load_all();
  }
});
