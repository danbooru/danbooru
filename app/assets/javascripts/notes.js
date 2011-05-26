Danbooru.Note = {
  Box: {
    create: function(id) {
      var $inner_border = $('<div/>');
      $inner_border.addClass("note-box-inner-border");
      $inner_border.css({opacity: 0.7});

      var $note_box = $('<div/>');
      $note_box.addClass("note-box");
      $note_box.data("id", id);
      $note_box.attr("data-id", id);
      $note_box.draggable({containment: "parent"});
      $note_box.resizable({
        containment: "parent", 
        handles: "se"
      });
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
    
    resize_inner_border: function($note_box) {
      var $inner_border = $note_box.find("div.note-box-inner-border");
      $inner_border.css({
        height: $note_box.height() - 2, 
        width: $note_box.width() - 2
      });
    },
    
    scale: function($note_box) {
      var $image = $("#image");
      var original_width = parseFloat($image.data("width"));
      var original_height = parseFloat($image.data("height"));
      var ratio = $image.width() / original_width;
      
      if (ratio < 1) {
        var scaled_width = original_width * ratio;
        var scaled_height = original_height * ratio;
        var scaled_top = $note_box.offset().top * ratio;
        var scaled_left = $note_box.offset().left * ratio;
        $note_box.css({
          top: scaled_top,
          left: scaled_left,
          width: scaled_width,
          height: scaled_height
        });
      }
    },
    
    descale: function($note_box) {
      var $image = $("#image");
      var original_width = parseFloat($image.data("width"));
      var original_height = parseFloat($image.data("height"));
      var ratio = $image.width() / original_width;
      
      if (ratio < 1) {
        var scaled_width = original_width * ratio;
        var scaled_height = original_height * ratio;
        var scaled_top = $note_box.offset().top * ratio;
        var scaled_left = $note_box.offset().left * ratio;
        $note_box.css({
          top: scaled_top,
          left: scaled_left,
          width: scaled_width,
          height: scaled_height
        });
      }
    }
  },
  
  Body: {
    create: function(id) {
      var $note_body = $('<div></div>');
      $note_body.addClass("note-body");
      $note_body.data("id", id);
      $note_body.attr("data-id", id);
      $note_body.hide();
      Danbooru.Note.Body.bind_events($note_body);
      return $note_body;
    },
    
    initialize: function($note_body) {
      var $note_box = $("#note-container div.note-box[data-id=" + $note_body.data("id") + "]");
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
      var $note_body = $("#note-container div.note-body[data-id=" + id + "]");
      $note_body.show();
      Danbooru.Note.Body.initialize($note_body);
    },
    
    hide: function(id) {
      var $note_body = $("#note-container div.note-body[data-id=" + id + "]");
      Danbooru.Note.timeouts.push($.timeout(250).done(function() {$note_body.hide();}));
    },
    
    hide_all: function() {
      $(".note-body").hide();
    },
    
    resize: function($note_body) {
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

      $note_body.click(function(e) {
        var $note_body_inner = $(e.currentTarget);
        Danbooru.Note.Edit.show($note_body_inner);
      })
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
        $textarea.val($note_body.html());
      }

      $dialog = $('<div></div>');
      $dialog.append($textarea);
      $dialog.data("id", $note_body.data("id"));
      $dialog.dialog({
        modal: true,
        width: 300,
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
      Danbooru.Note.editing = true;
    },
    
    save: function() {
      var $this = $(this);
      var $textarea = $this.find("textarea");
      var id = $this.data("id");
      var $note_body = $("#note-container .note-body[data-id=" + id + "]");
      var $note_box = $("#note-container .note-box[data-id=" + id + "]");
      var text = $textarea.val();
      Danbooru.Note.Body.set_text($note_body, text);
      $this.dialog("close");
      $note_box.find(".note-box-inner-border").removeClass("unsaved");
      console.log("save %d", id);
    },
    
    cancel: function() {
      $(this).dialog("close");
    },
    
    delete: function() {
      var $this = $(this);
      var id = $this.data("id");
      console.log("delete %d", id);
      $("#note-container .note-box[data-id=" + id + "]").remove();
      $("#note-container .note-body[data-id=" + id + "]").remove();
      $(this).dialog("close");
    },
    
    history: function() {
      var $this = $(this);
      var id = $this.data("id");
      console.log("history %d", id);
      $(this).dialog("close");
    }
  },
  
  TranslationMode: {
    start: function() {
      $("#note-container").click(Danbooru.Note.TranslationMode.create_note);
      $("#translate-button").one("click", Danbooru.Note.TranslationMode.stop).html("Click on image");
    },
    
    stop: function() {
      $("#note-container").unbind("click");
      $("#translate-button").one("click", Danbooru.Note.TranslationMode.start).html("Translate");
    },
    
    create_note: function(e) {
      var offset = $("#image").offset();
      Danbooru.Note.new(e.pageX - offset.left, e.pageY - offset.top);
      Danbooru.Note.TranslationMode.stop();
    }
  },
  
  Image: {
    resize: function() {
      var $image = $("#image");
      var max_width = parseInt($("meta[name=max-image-width]").attr("content"));
      var current_width = $image.width();
      var current_height = $image.height();
      if (current_width > max_width) {
        var ratio = max_width / current_width;
        $image.attr("ratio", ratio);
        $image.width(current_width * ratio).height(current_height * ratio).attr("resized", "1");
      }
    },
    
    reset_size: function() {
      var $image = $("#image");
      $image.width($image.data("width")).height($image.data("height")).attr("resized", "0");
    }
  },
  
  id: "x",
  dragging: false,
  editing: false,
  timeouts: [],
  pending: {},
  
  scale: function() {
    var $image = $("#image");
    if ($image.attr("ratio")) {
      
    }
  },
  
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
    Danbooru.Note.Box.scale($note_box);
    Danbooru.Note.Box.resize_inner_border($note_box);
    Danbooru.Note.Body.set_text($note_body, text);
  },
  
  new: function(x, y) {
    var $note_box = Danbooru.Note.Box.create(Danbooru.Note.id);
    var $note_body = Danbooru.Note.Body.create(Danbooru.Note.id);
    $note_box.offset({
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
  }
}

$(document).ready(function() {
  if ($("#c-posts #a-show").size > 0) {
    Danbooru.Note.Image.resize();
    $("#translate-button").one("click", Danbooru.Note.TranslationMode.start);
    $("#note-container").width($("#image").width()).height($("#image").height());
    // $(document).bind("keydown", "ctrl+n", Danbooru.Note.TranslationMode.start);

    $("#toggle-resize").click(function() {
      var $image = $("#image");
      if ($image.attr("resized") === "1") {
        Danbooru.Note.Image.reset_size();
      } else {
        Danbooru.Note.Image.resize();
      }
    });
  }
});
