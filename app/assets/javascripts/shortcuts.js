(function() {
  Danbooru.Shortcuts = {};

  Danbooru.Shortcuts.initialize = function() {
    Danbooru.keydown("s", "scroll_down", Danbooru.Shortcuts.nav_scroll_down);
    Danbooru.keydown("w", "scroll_up", Danbooru.Shortcuts.nav_scroll_up);

    Danbooru.keydown("q", "focus_search", function(e) {
      $("#tags, #search_name, #search_name_matches, #query").trigger("focus").selectEnd();
      e.preventDefault();
    });

    if ($("#image").length) { // post page or bookmarklet upload page
      Danbooru.keydown("shift+e", "edit_dialog", function(e) {
        if (Danbooru.meta("current-user-id") == "") { // anonymous
          return;
        }

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

    if ($("#c-posts #a-index, #c-favorites #a-index").length) {
      Danbooru.keydown("r", "random", function(e) {
        $("#random-post")[0].click();
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
  Danbooru.Shortcuts.initialize();
});
