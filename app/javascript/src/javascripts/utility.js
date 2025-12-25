import Rails from '@rails/ujs';
import { delegate, hideAll } from 'tippy.js';
import Notice from './notice';
import capitalize from "lodash/capitalize";
import Alpine from 'alpinejs';

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

// The following function returns true if beforeinput, and thus getTargetRanges, is supported.
//
// https://developer.mozilla.org/en-US/docs/Web/API/Element/beforeinput_event#feature_detection
export function isBeforeInputEventAvailable() {
  return (
    window.InputEvent &&
    typeof InputEvent.prototype.getTargetRanges === "function"
  );
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

// Upload a list of files or a URL to the site.
export async function uploadFilesOrURL(filesOrURL) {
  if (typeof filesOrURL === "string") {
    return uploadURL(filesOrURL);
  } else {
    return uploadFiles(filesOrURL);
  }
}

// Upload a list of files to the site.
// @param {File[]} files - The list of files to upload.
export async function uploadFiles(files) {
  let params = Object.fromEntries(Array.from(files).map((file, n) => [`upload[files][${n}]`, file]));

  return createUpload(params);
}

// Upload a URL to the site.
// @param {String} url - The URL to upload.
export async function uploadURL(url) {
  if (url.match(/^https?:\/\//)) {
    return createUpload({ "upload[source]": url });
  } else {
    throw new Error(`Invalid URL`);
  }
}

// Upload a list of files or a URL to the site. Throws an error if the upload fails.
//
// @param {Object} params - The parameters to pass to the upload endpoint.
// @param {Number} [pollDelay=250] - The delay in milliseconds between checking the upload status.
// @returns {Object} - The upload object containing the upload status and the list of uploaded media assets.
export async function createUpload(params, pollDelay = 250) {
  let formData = new FormData();

  for (let [key, value] of Object.entries(params)) {
    formData.append(key, value);
  }

  let response = await fetch("/uploads.json", {
    method: "POST",
    headers: { "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content },
    body: formData
  });

  let upload = await response.json();
  while (upload.status !== "completed" && !uploadError(upload)) {
    await delay(pollDelay);
    upload = await $.get(`/uploads/${upload.id}.json`);
  }

  let error = uploadError(upload);
  if (error) {
    throw new Error(error);
  }

  return upload;
}

// Return the error message for a failed upload.
export function uploadError(upload) {
  // The upload failed during processing (normally because the URL didn't contain any images)
  if (upload.status === "error") {
    return upload.error;
  // The upload failed with a 4xx or 5xx error (normally rate limiting)
  } else if (upload.success === false && upload.message) {
    return upload.message;
  // The upload failed with a validation error (normally an invalid URL or too many queued assets)
  } else if (upload.errors) {
    return errorFromResponse(upload);
  }
}

// Get the validation errors returned by an API call as a single string.
// Equivalent to `@model.errors.full_messages.join('; ')`.
export function errorFromResponse(apiResponse, separator = "; ") {
  let errors = apiResponse.errors ?? {};

  return Object.keys(errors).map(attribute => {
    return errors[attribute].map(error => {
      if (attribute === "base") {
        return `${error}`;
      } else {
        return `${capitalize(attribute)} ${error}`;
      }
    });
  }).join(separator);
}

// Call a function after all Alpine.js components on the page have been initialized.
// Like jQuery's `$(document).ready()`, but for Alpine.js.
export function alpineReady(callback) {
  if (Alpine._initialized) {
    callback();
  } else {
    $(document).on("alpine:initialized", callback);
  }
}

$.fn.replaceFieldText = function(new_value) {
  return this.each(function() {
    if (this.undoStack) {
      // If the element is using the custom undo stack implementation, simply assign directly to the input's value.
      this.undoStack.save("danbooru.replaceFieldText");
      this.value = new_value;
    } else {
      // Otherwise, try using execCommand to preserve the browser's native undo stack.
      this.focus();
      this.setSelectionRange(0, this.value.length);
      let success = document.execCommand("insertText", false, new_value);
      if (!success) {
        // insertText is not supported by the browser.
        // Fall back to assigning to value.
        this.value = new_value;
      }
    }
  })
}

$.fn.selectEnd = function() {
  return this.each(function() {
    this.focus();
    this.setSelectionRange(this.value.length, this.value.length);
  })
}

Utility.copyToClipboard = copyToClipboard;
Utility.printPage = printPage;
Utility.alpineReady = alpineReady;

export default Utility
