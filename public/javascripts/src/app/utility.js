(function() {
  Danbooru.Utility = {};
  
  Danbooru.Utility.j_alert = function(title, msg) {
    $('<div title="' + title + '"></div>').html(msg).dialog();
  }
  
  Danbooru.Utility.j_error = function(msg) {
    this.j_alert("Error", msg);
  }
})();

