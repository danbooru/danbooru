let Utility = {};

Utility.meta = function(key) {
  return $("meta[name=" + key + "]").attr("content");
}

Utility.test_max_width = function(width) {
  if (!window.matchMedia) {
    return false;
  }
  var mq = window.matchMedia('(max-width: ' + width + 'px)');
  return mq.matches;
}

Utility.scrolling = false;

Utility.scroll_to = function(element) {
  if (Utility.scrolling) {
    return;
  } else {
    Utility.scrolling = true;
  }

  var top = null;
  if (typeof element === "number") {
    top = element;
  } else {
    top = element.offset().top - 10;
  }
  $('html, body').animate({scrollTop: top}, 300, "linear", function() {Utility.scrolling = false;});
}

Utility.notice_timeout_id = undefined;

Utility.notice = function(msg, permanent) {
  $('#notice').addClass("ui-state-highlight").removeClass("ui-state-error").fadeIn("fast").children("span").html(msg);

  if (Utility.notice_timeout_id !== undefined) {
    clearTimeout(Utility.notice_timeout_id)
  }
  if (!permanent) {
    Utility.notice_timeout_id = setTimeout(function() {
      $("#close-notice-link").click();
      Utility.notice_timeout_id = undefined;
    }, 6000);
  }
}

Utility.error = function(msg) {
  $('#notice').removeClass("ui-state-highlight").addClass("ui-state-error").fadeIn("fast").children("span").html(msg);

  if (Utility.notice_timeout_id !== undefined) {
    clearTimeout(Utility.notice_timeout_id)
  }
}

Utility.keydown = function(keys, namespace, handler) {
  if (Utility.meta("enable-js-navigation") === "true") {
    $(document).on("keydown.danbooru." + namespace, null, keys, handler);
  }
};

Utility.is_subset = function(array, subarray) {
  var all = true;

  $.each(subarray, function(i, val) {
    if ($.inArray(val, array) === -1) {
      all = false;
    }
  });

  return all;
}

Utility.intersect = function(a, b) {
  a = a.slice(0).sort();
  b = b.slice(0).sort();
  var result = [];
  while (a.length > 0 && b.length > 0) {
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

Utility.without = function(array, element) {
  var temp = [];
  $.each(array, function(i, v) {
    if (v !== element) {
      temp.push(v);
    }
  });
  return temp;
}

Utility.reject = function(array, f) {
  var filtered = [];
  $.each(array, function(i, x) {
    if (!f(x)) {
      filtered.push(x);
    }
  });
  return filtered;
}

Utility.regexp_escape = function(string) {
  return string.replace(/([.?*+^$[\]\\(){}|-])/g, "\\$1");
}

Utility.sorttable = function(table) {
  table.stupidtable();
  table.bind("aftertablesort", function(event, data) {
    $("#c-saved-searches table tbody tr").removeClass("even odd");
    $("#c-saved-searches table tbody tr:even").addClass("even");
    $("#c-saved-searches table tbody tr:odd").addClass("odd");
  });
};

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

$.fn.selectEnd = function() {
  if (this.length) {
    this.selectRange(this.val().length, this.val().length);
  }
  return this;
}

$(function() {
  $(window).on("danbooru:notice", function(event, msg) {
    Utility.notice(msg);
  })

  $(window).on("danbooru:error", function(event, msg) {
    Utility.error(msg);
  })
});

export default Utility
