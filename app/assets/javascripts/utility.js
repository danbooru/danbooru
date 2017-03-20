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

  Danbooru.notice_timeout_id = undefined;

  Danbooru.notice = function(msg, permanent) {
    $('#notice').addClass("ui-state-highlight").removeClass("ui-state-error").fadeIn("fast").children("span").html(msg);

    if (Danbooru.notice_timeout_id !== undefined) {
      clearTimeout(Danbooru.notice_timeout_id)
    }
    if (!permanent) {
      Danbooru.notice_timeout_id = setTimeout(function() {
        $("#close-notice-link").click();
        Danbooru.notice_timeout_id = undefined;
      }, 6000);
    }
  }

  Danbooru.error = function(msg) {
    $('#notice').removeClass("ui-state-highlight").addClass("ui-state-error").fadeIn("fast").children("span").html(msg);

    if (Danbooru.notice_timeout_id !== undefined) {
      clearTimeout(Danbooru.notice_timeout_id)
    }
  }

  Danbooru.keydown = function(keys, namespace, handler) {
    if (Danbooru.meta("enable-js-navigation") === "true") {
      $(document).on("keydown" + ".danbooru." + namespace, null, keys, handler);
    }
  };

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

  Danbooru.get_url_parameter = function(sParam) {
    var sPageURL = decodeURIComponent(window.location.search.substring(1)),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : sParameterName[1];
      }
    }
  };

  Danbooru.sorttable = function(table) {
    table.stupidtable();
    table.bind("aftertablesort", function(event, data) {
      $("#c-saved-searches table tbody tr").removeClass("even odd");
      $("#c-saved-searches table tbody tr:even").addClass("even");
      $("#c-saved-searches table tbody tr:odd").addClass("odd");
    });
  };

  String.prototype.hash = function() {
    var hash = 5381, i = this.length;

    while(i)
      hash = (hash * 33) ^ this.charCodeAt(--i)

    return hash >>> 0;
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
    if (this.length) {
      this.selectRange(this.val().length, this.val().length);
    }
    return this;
  }
})();
