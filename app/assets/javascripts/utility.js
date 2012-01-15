(function() {
  Danbooru.meta = function(key) {
    return $("meta[name=" + key + "]").attr("content");
  }
  
  Danbooru.notice = function(msg) {
    $('#notice').html(msg).addClass("ui-state-highlight").removeClass("ui-state-error").fadeIn("fast");
  }
  
  Danbooru.error = function(msg) {
    $('#notice').html(msg).removeClass("ui-state-highlight").addClass("ui-state-error").fadeIn("fast");
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
