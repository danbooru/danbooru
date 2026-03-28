import Utility from './utility'
import { hideAll } from 'tippy.js';

let Shortcuts = {};

Shortcuts.initialize = function() {
  Utility.keydown("s", "scroll_down", Shortcuts.nav_scroll_down);
  Utility.keydown("w", "scroll_up", Shortcuts.nav_scroll_up);
  Utility.keydown("ctrl+return meta+return", "submit_form", Shortcuts.submit_form, 'input[type="text"], textarea');
  Utility.keydown("esc", "hide_tooltips", Shortcuts.hide_tooltips);
  Utility.keydown("shift+/", "keyboard_shortcuts", Shortcuts.keyboard_shortcuts);

  Shortcuts.initialize_nav_shortcuts();
  Shortcuts.initialize_data_shortcuts();
}

Shortcuts.NAV_KEYS = {
  p: "nav-posts",
  c: "nav-comments",
  n: "nav-notes",
  a: "nav-artists",
  t: "nav-tags",
  l: "nav-pools",
  w: "nav-wiki",
  f: "nav-forum",
  m: "nav-my-account",
};

Shortcuts.initialize_nav_shortcuts = function() {
  let gPressed = false;
  let timer = null;

  $(document).on("keydown.danbooru.nav_prefix", function(event) {
    if ($(event.target).is('input, textarea, select')) return;

    if (!gPressed) {
      if (event.key === "g" && !event.ctrlKey && !event.metaKey && !event.altKey && !event.shiftKey) {
        gPressed = true;
        timer = setTimeout(() => { gPressed = false; }, 1000);
        event.preventDefault();
      }
    } else {
      gPressed = false;
      clearTimeout(timer);

      const id = Shortcuts.NAV_KEYS[event.key];
      if (id) {
        const link = document.getElementById(id);
        if (link) link.click();
        event.preventDefault();
      }
    }
  });
};

// Bind keyboard shortcuts to links that have a `data-shortcut="..."` attribute. If multiple links have the
// same shortcut, then the first link that matches its condition will be triggered by the shortcut.
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
      const elements = $(`[data-shortcut="${keys}"]`);

      for (let i = 0; i < elements.length; i++) {
        const e = elements.get(i);
        const condition = $(e).attr("data-shortcut-when") || "*";

        if ($(e).is(condition)) {
          if ($(e).is('input[type="text"], textarea')) {
            $(e).focus().selectEnd();
          } else {
            e.click();
          }

          event.preventDefault();
          break;
        }
      }
    });
  });
};

Shortcuts.submit_form = function(event) {
  $(event.target).parents("form").find('[type="submit"]').click();
  event.preventDefault();
};

Shortcuts.nav_scroll_down = function() {
  window.scrollBy(0, $(window).height() * 0.15);
}

Shortcuts.nav_scroll_up = function() {
  window.scrollBy(0, $(window).height() * -0.15);
}

Shortcuts.hide_tooltips = function() {
  hideAll({ duration: 0 });
}

Shortcuts.keyboard_shortcuts = function() {
  $.get("/static/keyboard_shortcuts", function(html) {
    let content = $(html).find("#a-keyboard-shortcuts");
    $("<div>").append(content.children()).dialog({
      title: "Keyboard Shortcuts",
      width: 800,
      modal: true,
      close: function() {
        $(this).dialog("destroy");
      },
    });
  });
}

$(document).ready(function() {
  Shortcuts.initialize();
});

export default Shortcuts
