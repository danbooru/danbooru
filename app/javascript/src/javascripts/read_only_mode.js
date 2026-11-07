import Notice from "./notice";

const READ_ONLY_MESSAGE = "The site is in read-only mode. You can browse the site, but changes are disabled right now.";

$(document).on("ajaxError", (event, xhr) => {
  if (xhr?.getResponseHeader?.("X-Danbooru-Read-Only") === "true") {
    Notice.error(READ_ONLY_MESSAGE);
  }
});
