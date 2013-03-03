(function() {
  Danbooru.meta = function(key) {
    return $("meta[name=" + key + "]").attr("content");
  }

  Danbooru.notice = function(msg) {
    $('#notice').html(msg).addClass("ui-state-highlight").removeClass("ui-state-error").fadeIn("fast");
    var scroll_top = $("#notice");
    $('html, body').animate({
        scrollTop: scroll_top
    }, 250);
  }

  Danbooru.error = function(msg) {
    $('#notice').html(msg).removeClass("ui-state-highlight").addClass("ui-state-error").fadeIn("fast");
    var scroll_top = $("#notice");
    $('html, body').animate({
        scrollTop: scroll_top
    }, 250);
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
})();
