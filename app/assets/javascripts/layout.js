(function() {
  Danbooru.Layout = {};
  
  Danbooru.Layout.initialize = function() {
    if ($("#c-posts").length && $("#a-index").length) {
      $(window).resize(Danbooru.Layout.restyle_content);
      Danbooru.Layout.restyle_content();
    }
  }
  
  Danbooru.Layout.restyle_content = function() {
    if ($(window).width() > 1100) {
      $("#content").css("width", "50em");
    } 
    
    if ($(window).width() > 1300) {
      $("#content").css("width", "60em");
    } 
    
    if ($(window).width() > 1500) {
      $("#content").css("width", "70em");
    } 
    
    if ($(window).width() < 1000) {
      $("#content").css("width", "40em");
    }
  }
})();

$(document).ready(function() {
  Danbooru.Layout.initialize();
});
