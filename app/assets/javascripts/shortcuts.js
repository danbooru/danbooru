(function() {
  Danbooru.Shortcuts = {};

  Danbooru.Shortcuts.initialize = function() {
    $(document).bind("keydown", "s", function(e) {
      Danbooru.Shortcuts.nav_scroll_down();
    });

    $(document).bind("keydown", "w", function(e) {
      Danbooru.Shortcuts.nav_scroll_up();
    });

    $(document).bind("keydown", "q", function(e) {
      $("#tags, #search_name, #search_name_matches, #query").trigger("focus").selectEnd();
      e.preventDefault();
    });
  }

  Danbooru.Shortcuts.nav_scroll_down = function() {
    var scroll_top = $(window).scrollTop() + ($(window).height() * 0.85);
    Danbooru.scroll_to(scroll_top);
  }

  Danbooru.Shortcuts.nav_scroll_up = function() {
    var scroll_top = $(window).scrollTop() - ($(window).height() * 0.85);
    if (scroll_top < 0) {
      scroll_top = 0;
    }
    Danbooru.scroll_to(scroll_top);
  }
})();


$(document).ready(function() {
  Danbooru.Shortcuts.initialize();
});
