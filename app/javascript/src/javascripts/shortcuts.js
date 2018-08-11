import Utility from './utility'
import Post from './posts.js.erb'

let Shortcuts = {};

Shortcuts.initialize = function() {
  Utility.keydown("s", "scroll_down", Shortcuts.nav_scroll_down);
  Utility.keydown("w", "scroll_up", Shortcuts.nav_scroll_up);
  Shortcuts.initialize_data_shortcuts();

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

// Bind keyboard shortcuts to links that have a `data-shortcut="..."` attribute. If multiple links have the
// same shortcut, then only the first link will be triggered by the shortcut.
//
// Add `data-shortcut-when="$selector"`, where `selector` is any valid jQuery selector, to make the shortcut
// active only when the link matches the selector. For example, `data-shortcut-when=":visible"` makes the
// shortcut apply only when the link is visible.
Shortcuts.initialize_data_shortcuts = function() {
  $(document).off("keydown.danbooru.shortcut");

  $("[data-shortcut]").each((_i, element) => {
    const id = $(element).attr("id");
    const keys = $(element).attr("data-shortcut");
    const namespace = `shortcut.${id}`;

    const title = `Shortcut is ${keys.split(/\s+/).join(" or ")}`;
    $(element).attr("title", title);

    Utility.keydown(keys, namespace, event => {
      const e = $(`[data-shortcut="${keys}"]`).get(0);
      const condition = $(e).attr("data-shortcut-when") || "*";

      if ($(e).is(condition)) {
        if ($(e).is("input, textarea")) {
          e.focus();
        } else {
          e.click();
        }

        event.preventDefault();
      }
    });
  });
};

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
