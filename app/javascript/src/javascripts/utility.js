import Rails from '@rails/ujs';
import { delegate, hideAll } from 'tippy.js';
import Notice from './notice';

let Utility = {};

export function clamp(value, low, high) {
  return Math.max(low, Math.min(value, high));
}

export function delay(milliseconds) {
  return new Promise(resolve => setTimeout(resolve, milliseconds));
}

Utility.meta = function(key) {
  return $("meta[name=" + key + "]").attr("content");
}

export function isTouchscreen() {
  return window.matchMedia("(pointer: coarse)").matches;
}

export function isMobile() {
  return window.matchMedia("(max-width: 660px)").matches;
}

Utility.dialog = function(title, html) {
  const $dialog = $(html).dialog({
    title: title,
    width: 700,
    modal: true,
    close: function() {
      // Defer removing the dialog to avoid detaching the <form> tag before the
      // form is submitted (which would prevent the submission from going through).
      $(() => $dialog.dialog("destroy"));
    },
    buttons: {
      "Submit": function() {
        let form = $dialog.find("form").get(0);

        if (form.requestSubmit) {
          form.requestSubmit();
        } else {
          form.submit();
          Rails.fire(form, "submit");
        }
      },
      "Cancel": function() {
        $dialog.dialog("close");
      }
    }
  });

  $dialog.find("form").on("submit.danbooru", function() {
    $dialog.dialog("close");
  });

  // XXX hides the popup menu when the Report comment button is clicked.
  hideAll({ duration: 0 });
}

Utility.keydown = function(keys, namespace, handler, selector = document) {
  $(selector).on("keydown.danbooru." + namespace, null, keys, handler);
};

export function splitWords(string) {
  return string?.match(/\S+/g) || [];
}

export async function copyToClipboard(text, message = "Copied!") {
  try {
    await navigator.clipboard.writeText(text);
    Notice.info(message);
  } catch (error) {
    Notice.error("Couldn't copy to clipboard");
  }
}

export function printPage(url) {
  let iframe = document.createElement("iframe");
  iframe.style.display = "none";
  iframe.src = url;
  iframe.onload = () => iframe.contentWindow.print();
  document.body.appendChild(iframe);
}

export function createTooltip(name, options = {}) {
  return delegate("body", {
    allowHTML: true,
    interactive: true,
    maxWidth: "none",
    theme: `common-tooltip ${name}`,
    appendTo: document.querySelector("#tooltips"),
    popperOptions: {
      modifiers: [
        {
          name: "eventListeners",
          enabled: false,
        },
      ],
    },
    ...options
  });
}

$.fn.selectEnd = function() {
  return this.each(function() {
    this.focus();
    this.setSelectionRange(this.value.length, this.value.length);
  })
}

Utility.copyToClipboard = copyToClipboard;
Utility.printPage = printPage;

export default Utility
