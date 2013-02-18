(function() {
  Danbooru.Layout = {};
  
  Danbooru.Layout.initialize = function() {
    $(window).resize(Danbooru.Layout.restyle_content);
  }
  
  Danbooru.Layout.restyle_content = function() {
    if ($(window).width() > 1100) {
      $("#content").css("max-width", "50em");
    }

    if ($(window).width() > 1300) {
      $("#content").css("max-width", "60em");
    }

    if ($(window).width() > 1500) {
      $("#content").css("max-width", "70em");
    }

    if ($(window).width() < 1000) {
      $("#content").css("max-width", "40em");
    }
  }
})();

$(document).ready(function() {
  Danbooru.Layout.initialize();
});
