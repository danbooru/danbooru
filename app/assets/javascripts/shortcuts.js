(function() {
  Danbooru.Shortcuts = {};

  Danbooru.Shortcuts.initialize = function() {
    $(document).bind("keypress", "s", function(e) {
      Danbooru.Shortcuts.nav_scroll_down();
    });

    $(document).bind("keypress", "w", function(e) {
      Danbooru.Shortcuts.nav_scroll_up();
    });

    $(document).bind("keypress", "q", function(e) {
      $("#tags, #search_name, #search_name_matches, #query").trigger("focus").selectEnd();
      e.preventDefault();
    });

    if ($("#image").length) {
      $(document).bind("keypress", "shift+o", function(e) {
        Danbooru.Post.approve(Danbooru.meta("post-id"));
      });

      $(document).bind("keypress", "shift+e", function(e) {
        if (!$("#edit-dialog").length) {
          $("#edit").show();
          $("#comments").hide();
          $("#share").hide();
          $("#post-sections li").removeClass("active");
          $("#post-edit-link").parent("li").addClass("active");
          $("#related-tags-container").show();

          Danbooru.Post.open_edit_dialog();
        }
        e.preventDefault();
      });
    }
  }

  Danbooru.Shortcuts.nav_scroll_down = function() {
    var scroll_top = $(window).scrollTop() + ($(window).height() * 0.15);
    $(window).scrollTop(scroll_top);
  }

  Danbooru.Shortcuts.nav_scroll_up = function() {
    var scroll_top = $(window).scrollTop() - ($(window).height() * 0.15);
    if (scroll_top < 0) {
      scroll_top = 0;
    }
    $(window).scrollTop(scroll_top);
  }
})();


$(document).ready(function() {
  if (Danbooru.meta("enable-js-navigation") === "true") {
    Danbooru.Shortcuts.initialize();
  }
});
