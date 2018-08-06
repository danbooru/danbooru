import Utility from './utility'
import Post from './posts.js.erb'

let Shortcuts = {};

Shortcuts.initialize = function() {
  Utility.keydown("s", "scroll_down", Shortcuts.nav_scroll_down);
  Utility.keydown("w", "scroll_up", Shortcuts.nav_scroll_up);

  Utility.keydown("q", "focus_search", function(e) {
    $("#tags, #search_name, #search_name_matches, #query").trigger("focus").selectEnd();
    e.preventDefault();
  });

  if ($("#image").length) { // post page or bookmarklet upload page
    Utility.keydown("shift+e", "edit_dialog", function(e) {
      if (Utility.meta("current-user-id") === "") { // anonymous
        return;
      }

      if (!$("#edit-dialog").length) {
        $("#edit").show();
        $("#comments").hide();
        $("#share").hide();
        $("#post-sections li").removeClass("active");
        $("#post-edit-link").parent("li").addClass("active");
        $("#related-tags-container").show();

        Post.open_edit_dialog();
      }
      e.preventDefault();
    });
  }

  if ($("#c-posts #a-index, #c-favorites #a-index").length) {
    Utility.keydown("r", "random", function(e) {
      $("#random-post")[0].click();
    });
  }
}

Shortcuts.nav_scroll_down = function() {
  var scroll_top = $(window).scrollTop() + ($(window).height() * 0.15);
  $(window).scrollTop(scroll_top);
}

Shortcuts.nav_scroll_up = function() {
  var scroll_top = $(window).scrollTop() - ($(window).height() * 0.15);
  if (scroll_top < 0) {
    scroll_top = 0;
  }
  $(window).scrollTop(scroll_top);
}

$(document).ready(function() {
  Shortcuts.initialize();
});

export default Shortcuts
