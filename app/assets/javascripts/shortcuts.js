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

    if ($("#image").length) { // post page or bookmarklet upload page
      $(document).bind("keydown", "shift+e", function(e) {
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

    if ($("#c-posts").length && $("#a-show").length) {
      $(document).bind("keydown", "shift+o", function(e) {
        if (Danbooru.meta("current-user-can-approve-posts") === "true") {
          Danbooru.Post.approve(Danbooru.meta("post-id"));
        }
      });

      $(document).bind("keydown", "r", function(e) {
        $("#random-post")[0].click();
      });
    }

    if ($("#c-posts").length && $("#a-index").length) {
      $(document).bind("keydown", "r", function(e) {
        $("#random-post")[0].click();
      });
    }

    if ($("#c-favorites").length && $("#a-index").length) {
      $(document).bind("keydown", "r", function(e) {
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
  if (Danbooru.meta("enable-js-navigation") === "true") {
    Danbooru.Shortcuts.initialize();
  }
});
