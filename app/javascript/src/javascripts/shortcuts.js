import Utility from './utility'

let Shortcuts = {};

Shortcuts.initialize = function() {
  Utility.keydown("s", "scroll_down", Shortcuts.nav_scroll_down);
  Utility.keydown("w", "scroll_up", Shortcuts.nav_scroll_up);
  Shortcuts.initialize_data_shortcuts();
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
          $(e).focus().selectEnd();
        } else {
          e.click();
        }

        event.preventDefault();
      }
    });
  });
};

Shortcuts.nav_scroll_down = function() {
  window.scrollBy(0, $(window).height() * 0.15);
}

Shortcuts.nav_scroll_up = function() {
  window.scrollBy(0, $(window).height() * -0.15);
}

$(document).ready(function() {
  Shortcuts.initialize();
});

export default Shortcuts
