(function() {
  Danbooru.meta = function(key) {
    return $("meta[name=" + key + "]").attr("content");
  }

  Danbooru.scrolling = false;

  Danbooru.scroll_to = function(element) {
    if (Danbooru.scrolling) {
      return;
    } else {
      Danbooru.scrolling = true;
    }

    var top = null;
    if (typeof(element) === "number") {
      top = element;
    } else {
      top = element.offset().top - 10;
    }
    $('html, body').animate({scrollTop: top}, 300, "linear", function() {Danbooru.scrolling = false;});
  }

  Danbooru.notice = function(msg) {
    $('#notice').addClass("ui-state-highlight").removeClass("ui-state-error").fadeIn("fast").children("span").html(msg);
  }

  Danbooru.error = function(msg) {
    $('#notice').removeClass("ui-state-highlight").addClass("ui-state-error").fadeIn("fast").children("span").html(msg);
    Danbooru.scroll_to($("#notice"));
  }

  Danbooru.is_subset = function(array, subarray) {
    var all = true;

    $.each(subarray, function(i, val) {
      if ($.inArray(val, array) === -1) {
        all = false;
      }
    });

    return all;
  }

  Danbooru.intersect = function(a, b) {
    a = a.slice(0).sort();
    b = b.slice(0).sort();
    var result = [];
    while (a.length > 0 && b.length > 0)
    {
      if (a[0] < b[0]) {
        a.shift();
      } else if (a[0] > b[0]) {
        b.shift();
      } else {
        result.push(a.shift());
        b.shift();
      }
    }
    return result;
  }

  Danbooru.without = function(array, element) {
    var temp = [];
    $.each(array, function(i, v) {
      if (v !== element) {
        temp.push(v);
      }
    });
    return temp;
  }

  Danbooru.reject = function(array, f) {
    var filtered = [];
    $.each(array, function(i, x) {
      if (!f(x)) {
        filtered.push(x);
      }
    });
    return filtered;
  }

  Danbooru.regexp_escape = function(string) {
    return string.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1");
  }

  $.fn.selectRange = function(start, end) {
    return this.each(function() {
      if (this.setSelectionRange) {
        this.focus();
        this.setSelectionRange(start, end);
      } else if (this.createTextRange) {
        var range = this.createTextRange();
        range.collapse(true);
        range.moveEnd('character', end);
        range.moveStart('character', start);
        range.select();
      }
    });
  };

  $.fn.selectEnd = function(){
    this.selectRange(this.val().length, this.val().length);
    return this;
  }
})();
