import CurrentUser from './current_user';
import Utility from './utility';
import { delegate, hideAll } from 'tippy.js';
import 'tippy.js/dist/tippy.css';

let PostTooltip = {};

PostTooltip.POST_SELECTOR = "*:not(.ui-sortable-handle) > .post-preview img, .dtext-post-id-link";
PostTooltip.SHOW_DELAY = 500;
PostTooltip.HIDE_DELAY = 125;
PostTooltip.DURATION = 250;

PostTooltip.initialize = function () {
  if (PostTooltip.disabled()) {
    return;
  }

  delegate("body", {
    allowHTML: true,
    appendTo: document.querySelector("#post-tooltips"),
    delay: [PostTooltip.SHOW_DELAY, PostTooltip.HIDE_DELAY],
    duration: PostTooltip.DURATION,
    interactive: true,
    maxWidth: "none",
    target: PostTooltip.POST_SELECTOR,
    theme: "common-tooltip post-tooltip",
    touch: false,

    onCreate: PostTooltip.on_create,
    onShow: PostTooltip.on_show,
    onHide: PostTooltip.on_hide,
  });

  $(document).on("click.danbooru.postTooltip", ".post-tooltip-disable", PostTooltip.on_disable_tooltips);
};

PostTooltip.on_create = function (instance) {
  let title = instance.reference.getAttribute("title");

  if (title) {
    instance.reference.setAttribute("data-title", title);
    instance.reference.setAttribute("title", "");
  }
};

PostTooltip.on_show = async function (instance) {
  let post_id = null;
  let preview = false;
  let $target = $(instance.reference);
  let $tooltip = $(instance.popper);

  hideAll({ exclude: instance });

  // skip if tooltip has already been rendered.
  if ($tooltip.has(".post-tooltip-body").length) {
    return;
  }

  if ($target.is(".dtext-post-id-link")) {
    preview = true;
    post_id = /\/posts\/(\d+)/.exec($target.attr("href"))[1];
  } else {
    post_id = $target.parents("[data-id]").data("id");
  }

  try {
    $tooltip.addClass("tooltip-loading");

    instance._request = $.get(`/posts/${post_id}`, { variant: "tooltip", preview: preview });
    let html = await instance._request;
    instance.setContent(html);

    $tooltip.removeClass("tooltip-loading");
  } catch (error) {
    if (error.status !== 0 && error.statusText !== "abort") {
      Utility.error(`Error displaying tooltip for post #${post_id} (error: ${error.status} ${error.statusText})`);
    }
  }
};

PostTooltip.on_hide = function (instance) {
  if (instance._request?.state() === "pending") {
    instance._request.abort();
  }
}

PostTooltip.disabled = function (event) {
  return CurrentUser.data("disable-post-tooltips");
};

PostTooltip.on_disable_tooltips = async function (event) {
  event.preventDefault();
  hideAll();

  if (CurrentUser.data("is-anonymous")) {
    Utility.notice('You must <a href="/session/new">login</a> to disable tooltips');
    return;
  }

  await CurrentUser.update({ disable_post_tooltips: true });
  Utility.notice("Tooltips disabled; check your account settings to re-enable.");
  location.reload();
};

$(document).ready(PostTooltip.initialize);

export default PostTooltip
