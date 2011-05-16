(function() {
  Danbooru.Note = function() {}
  
  Danbooru.Note.initialize_all = function() {
    $("#note-container").width($("#image").width());
    $("#note-container").height($("#image").height());
    
    $("a#translate").click(function(e) {
      e.preventDefault();
      Danbooru.Note.create(1);
    });
  }
  
  Danbooru.Note.prototype.getElement = function(name, unwrap) {
    var element = $("#note-" + name + "-" + this.id);
    
    if (unwrap) {
      return element[0];
    } else {
      return element;
    }
  }
  
  Danbooru.Note.prototype.getBox = function(unwrap) {
    return this.getElement("box", unwrap);
  }
  
  Danbooru.Note.prototype.getImage = function(unwrap) {
    return this.getElement("image", unwrap);
  }

  Danbooru.Note.prototype.getBody = function(unwrap) {
    return this.getElement("body", unwrap);
  }

  Danbooru.Note.prototype.getCorner = function(unwrap) {
    return this.getElement("corner", unwrap);
  }
  
  Danbooru.Note.prototype.initialize = function(id, is_new, raw_body) {
    if (Note.debug) {
      console.debug("Note#initialize (id=%d)", id);
    }
    
    this.id = id;
    this.is_new = is_new;

    // Cache the dimensions
    this.fullsize = {
      left: this.getBox().offset().left,
      top: this.getBox().offset().top,
      width: this.getBox().width(),
      height: this.getBox().height()
    }
    
    // Store the original values (in case the user clicks Cancel)
    this.old = {
      raw_body: raw_body,
      formatted_body: this.getBody().html()
    }
    
    for (p in this.fullsize) {
      this.old[p] = this.fullsize[p];
    }

    // Make the note translucent
    if (is_new) {
      this.getBox().css({opacity: 0.2});
    } else {
      this.getBox().css({opacity: 0.5});
    }

    if (is_new && raw_body == '') {
      this.bodyfit = true;
      this.getBody().css({height: 100});
    }

    // Attach the event listeners
    this.getBox().mousedown(this.dragStart);
    this.getBox().mouseout(this.bodyHideTimer);
    this.getBox().mouseover(this.bodyShow);
    this.getCorner().mousedown(this.resizeStart);
    this.getBody().mouseover(this.bodyShow);
    this.getBody().mouseout(this.bodyHideTimer);
    this.getBody().click(this.showEditBox);

    this.adjustScale();
  }
  
  // Returns the raw text value of this note
  Danbooru.Note.prototype.textValue = function() {
    if (Note.debug) {
      console.debug("Note#textValue (id=%d)", this.id);
    }
    
    return this.old.raw_body.trim();
  }
  
  // Removes the edit box
  Danbooru.Note.prototype.hideEditBox = function(e) {
    if (Note.debug) {
      console.debug("Note#hideEditBox (id=%d)", this.id)
    }
    
    var id = $("#edit-box").data("id");

    if (id != null) {
      $("#edit-box").unbind();
      $("#note-save-" + id).unbind();
      $("#note-cancel-" + id).unbind();
      $("#note-remove-" + id).unbind();
      $("#note-history-" + id).unbind();
      $("#edit-box").remove();
    }
  }
  
  // Shows the edit box
  Danbooru.Note.prototype.showEditBox = function(e) {
    if (Note.debug) {
      console.debug("Note#showEditBox (id=%d)", this.id);
    }
    
    this.hideEditBox(e);

    var insertionPosition = this.getInsertionPosition();
    var top = insertionPosition[0];
    var left = insertionPosition[1];
    html += '<div id="edit-box" style="top: '+top+'px; left: '+left+'px; position: absolute; visibility: visible; z-index: 100; background: white; border: 1px solid black; padding: 12px;">';
    html += '<form onsubmit="return false;" style="padding: 0; margin: 0;">';
    html += '<textarea rows="7" id="edit-box-text" style="width: 350px; margin: 2px 2px 12px 2px;">' + this.textValue() + '</textarea>';
    html += '<input type="submit" value="Save" name="save" id="note-save-' + this.id + '">';
    html += '<input type="submit" value="Cancel" name="cancel" id="note-cancel-' + this.id + '">';
    html += '<input type="submit" value="Delete" name="remove" id="note-remove-' + this.id + '">';
    html += '<input type="submit" value="History" name="history" id="note-history-' + this.id + '">';
    html += '</form>';
    html += '</div>';
    $("#note-container").append(html);
    $('#edit-box').data("id", this.id);
    $("#edit-box").mousedown(this.editDragStart);
    $("#note-save-" + this.id).click(this.save);
    $("#note-cancel-" + this.id).click(this.cancel);
    $("#note-remove-" + this.id).click(this.remove);
    $("#note-history-" + this.id).click(this.history)
    $("#edit-box-text").focus();
  }
  
  // Shows the body text for the note
  Danbooru.Note.prototype.bodyShow = function(e) {
    if (Note.debug) {
      console.debug("Note#bodyShow (id=%d)", this.id);
    }
    
    if (this.dragging) {
      return;
    }

    if (this.hideTimer) {
      this.hideTimer.clear();
    }

    if (Note.noteShowingBody == this) {
      return;
    }
    
    if (Note.noteShowingBody) {
      Note.noteShowingBody.bodyHide();
    }
    
    Note.noteShowingBody = this;

    if (Note.zindex >= 9) {
      /* don't use more than 10 layers (+1 for the body, which will always be above all notes) */
      Note.zindex = 0;
      for (var i=0; i< Note.all.length; ++i) {
        Note.all[i].getBox().css({zIndex: 0});
      }
    }

    this.getBox().css({zIndex: ++Note.zindex});
    this.getBody().css({zIndex: 10, top: 0, left: 0});
    var dw = document.documentElement.scrollWidth;
    this.getBody().css({visibility: "hidden", display: "block"});
    if (!this.bodyfit) {
      this.getBody().css({height: "auto", minWidth: 140});
      var w = this.getBody(true).offsetWidth;
      var h = this.getBody(true).offsetHeight;
      var lo = null;
      var hi = null;
      var x = null;
      var last = null;
      if (this.getBody(true).scrollWidth <= this.getBody(true).clientWidth) {
        /* for short notes (often a single line), make the box no wider than necessary */  
        // scroll test necessary for Firefox
        lo = 20;
        hi = w;
  
        do {
          x = (lo+hi)/2
          this.getBody().css({minWidth: x});
          if (this.getBody(true).offsetHeight > h) {
            lo = x;
          } else {
            hi = x;
          }
        } while ((hi - lo) > 4);
        if (this.getBody(true).offsetHeight > h) {
          this.getBody().css({minWidth: hi});
        }
      }
      
      if ($.browser.msie) {
        // IE7 adds scrollbars if the box is too small, obscuring the text
        if (this.getBody(true).offsetHeight < 35) {
          this.getBody().css({minHeight: 35});
        }
        
        if (this.getBody(true).offsetWidth < 47) {
          this.getBody().css({minWidth: 47});
        }
      }
      this.bodyfit = true;
    }
    this.getBody().css({
      top: this.getBox(true).offsetTop + this.getBox(true).clientHeight + 5
    });

    // keep the box within the document's width
    var l = 0;
    var e = this.getBox(true);
    do {
      l += e.offsetLeft
    } while (e = e.offsetParent);
    l += this.getBody(true).offsetWidth + 10 - dw;
    if (l > 0) {
      this.getBody().css({left: this.getBox(true).offsetLeft - l});
    } else {
      this.getBody().css({left: this.getBox(true).offsetLeft});
    }
    this.getBody().css({visibility: "visible"});
  }
  
  Danbooru.Note.prototype.bodyHideTimer = function(e) {
    if (Note.debug) {
      console.debug("Note#bodyHideTimer (id=%d)", this.id);
    }
    this.hideTimer = $.timeout(250).done(this.bodyHide);
  }
  
  // Start dragging the note
  Danbooru.Note.prototype.dragStart = function(e) {
    if (Note.debug) {
      console.debug("Note#dragStart (id=%d)", this.id);
    }
    
    $(document).mousemove(this.drag);
    $(document).mouseup(this.dragStop);
    $(document).select(function(e) {e.preventDefault();});

    this.cursorStartX = e.pageX;
    this.cursorStartY = e.pageY;
    this.boxStartX = this.getBox().offset().left;
    this.boxStartY = this.getBox().offset().top;
    this.boundsX = new ClipRange(5, this.getImage(true).clientWidth - this.getBox(true).clientWidth - 5);
    this.boundsY = new ClipRange(5, this.getImage(true).clientHeight - this.getBox(true).clientHeight - 5);
    this.dragging = true;
    this.bodyHide();
  }
  
  // Stop dragging the note
  Danbooru.Note.prototype.dragStop = function(e) {
    if (Note.debug) {
      console.debug("Note#dragStop (id=%d)", this.id);
    }
    
    $(document).unbind();

    this.cursorStartX = null;
    this.cursorStartY = null;
    this.boxStartX = null;
    this.boxStartY = null;
    this.boundsX = null;
    this.boundsY = null;
    this.dragging = false;

    this.bodyShow();
  }
  
  Danbooru.Note.prototype.ratio = function() {
    return this.getImage().width() / parseFloat(this.getImage().data("original-width"));
  }
  
  // Scale the notes for when the image gets resized
  Danbooru.Note.prototype.adjustScale = function() {
    if (Note.debug) {
      console.debug("Note#adjustScale (id=%d)", this.id);
    }
    
    var ratio = this.ratio();
    this.getBox().css({
      left: this.fullsize.left * ratio,
      top: this.fullsize.top * ratio,
      width: this.fullsize.width * ratio,
      height: this.fullsize.height * ratio
    });
  }
  
  // Update the note's position as it gets dragged
  Danbooru.Note.prototype.drag = function(e) {
    var left = this.boxStartX + e.pageX - this.cursorStartX;
    var top = this.boxStartY + e.pageY - this.cursorStartY;
    left = this.boundsX.clip(left);
    top = this.boundsY.clip(top);
    this.getBox().css({left: left, top: top});
    var ratio = this.ratio();
    this.fullsize.left = left / ratio;
    this.fullsize.top = top / ratio;

    e.preventDefault();
  }
  
  // Start dragging the edit box
  Danbooru.Note.prototype.editDragStart = function(e) {
    if (Note.debug) {
      console.debug("Note#editDragStart (id=%d)", this.id);
    }
    
    var node = e.element().nodeName;
    if (node != 'FORM' && node != 'DIV') {
      return
    }

    document.observe("mousemove", this.editDrag.bindAsEventListener(this))
    document.observe("mouseup", this.editDragStop.bindAsEventListener(this))
    document.observe("selectstart", function() {return false})

    this.elements.editBox = $('edit-box');
    this.cursorStartX = e.pointerX()
    this.cursorStartY = e.pointerY()
    this.editStartX = this.elements.editBox.offsetLeft
    this.editStartY = this.elements.editBox.offsetTop
    this.dragging = true
  }
})();

$(document).ready(function() {
  Danbooru.Note.initialize_all();
});
