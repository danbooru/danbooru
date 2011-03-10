(function() {
  Danbooru.meta = function(key) {
    return $("meta[name=" + key + "]").attr("content");
  }
  
  Danbooru.j_alert = function(title, msg) {
    $('<div title="' + title + '"></div>').html(msg).dialog();
  }
  
  Danbooru.j_error = function(msg) {
    this.j_alert("Error", msg);
  }
  
  Danbooru.ajax_start = function(element) {
    $(element).after(' <span class="wait">...</span>');
  }
  
  Danbooru.ajax_stop = function(element) {
    $(element).next("span.wait").remove();
  }
})();
