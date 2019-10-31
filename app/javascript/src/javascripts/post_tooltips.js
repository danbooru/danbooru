import CurrentUser from './current_user'
import Utility from './utility'

require('qtip2');
require('qtip2/dist/jquery.qtip.css');

let PostTooltip = {};

PostTooltip.render_tooltip = async function (event, qtip) {
  let post_id = null;
  let preview = false;

  if ($(this).is(".dtext-post-id-link")) {
    preview = true;
    post_id = /\/posts\/(\d+)/.exec($(this).attr("href"))[1];
  } else {
    post_id = $(this).parents("[data-id]").data("id");
  }

  try {
    qtip.cache.request = $.get(`/posts/${post_id}`, { variant: "tooltip", preview: preview });
    let html = await qtip.cache.request;

    qtip.set("content.text", html);
    qtip.elements.tooltip.removeClass("post-tooltip-loading");
  } catch (error) {
    if (error.status !== 0 && error.statusText !== "abort") {
      Utility.error(`Error displaying tooltip for post #${post_id} (error: ${error.status} ${error.statusText})`);
    }
  }
};

// Hide the tooltip the first time it is shown, while we wait on the ajax call to complete.
PostTooltip.on_show = function (event, qtip) {
  if (!qtip.cache.hasBeenShown) {
    qtip.elements.tooltip.addClass("post-tooltip-loading");
    qtip.cache.hasBeenShown = true;
  }
};

PostTooltip.POST_SELECTOR = "*:not(.ui-sortable-handle) > .post-preview img, .dtext-post-id-link";

// http://qtip2.com/options
PostTooltip.QTIP_OPTIONS = {
  style: {
    classes: "qtip-light post-tooltip",
    tip: false
  },
  content: PostTooltip.render_tooltip,
  overwrite: false,
  position: {
    viewport: true,
    my: "bottom left",
    at: "top left",
    effect: false,
    adjust: {
      y: -2,
      method: "shift",
    },
  },
  show: {
    solo: true,
    delay: 750,
    effect: false,
    ready: true,
    event: "mouseenter",
  },
  hide: {
    delay: 250,
    fixed: true,
    effect: false,
    event: "unfocus click mouseleave",
  },
  events: {
    show: PostTooltip.on_show,
  },
};

PostTooltip.initialize = function () {
  $(document).on("mouseenter.danbooru.postTooltip", PostTooltip.POST_SELECTOR, function (event) {
    if (PostTooltip.disabled()) {
      $(this).qtip("disable");
    } else {
      $(this).qtip(PostTooltip.QTIP_OPTIONS, event);
    }
  });

  // Cancel pending ajax requests when we mouse out of the thumbnail.
  $(document).on("mouseleave.danbooru.postTooltip", PostTooltip.POST_SELECTOR, function (event) {
    let qtip = $(event.target).qtip("api");

    if (qtip && qtip.cache && qtip.cache.request && qtip.cache.request.state() === "pending") {
      qtip.cache.request.abort();
    }
  });

  $(document).on("click.danbooru.postTooltip", ".post-tooltip-disable", PostTooltip.on_disable_tooltips);

  // Hide tooltips when pressing keys or clicking thumbnails.
  $(document).on("keydown.danbooru.postTooltip", PostTooltip.hide);
  $(document).on("click.danbooru.postTooltip", PostTooltip.POST_SELECTOR, PostTooltip.hide);

  // Disable tooltips on touch devices. https://developer.mozilla.org/en-US/docs/Web/API/Touch_events/Supporting_both_TouchEvent_and_MouseEvent
  PostTooltip.isTouching = false;
  $(document).on("touchstart.danbooru.postTooltip", function (event) { PostTooltip.isTouching = true; });
  $(document).on("touchend.danbooru.postTooltip",   function (event) { PostTooltip.isTouching = false; });
};

PostTooltip.hide = function (event) {
  // Hide on any key except control (user may be control-clicking link inside tooltip).
  if (event.type === "keydown" && event.ctrlKey === true) {
    return;
  }

  $(".post-tooltip:visible").qtip("hide");
};

PostTooltip.disabled = function (event) {
  return PostTooltip.isTouching || CurrentUser.data("disable-post-tooltips");
};

PostTooltip.on_disable_tooltips = async function (event) {
  event.preventDefault();
  $(event.target).parents(".qtip").qtip("hide");

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
