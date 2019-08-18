import Utility from './utility'

require('qtip2');
require('qtip2/dist/jquery.qtip.css');

let PostTooltip = {};

PostTooltip.render_tooltip = function (event, qtip) {
  var post_id = $(this).parents("[data-id]").data("id");

  $.get("/posts/" + post_id, { variant: "tooltip" }).then(function (html) {
    qtip.set("content.text", html);
    qtip.elements.tooltip.removeClass("post-tooltip-loading");

    // Hide the tooltip if the user stopped hovering before the ajax request completed.
    if (PostTooltip.lostFocus) {
      qtip.hide();
    }
  });
};

// Hide the tooltip the first time it is shown, while we wait on the ajax call to complete.
PostTooltip.on_show = function (event, qtip) {
  if (!qtip.cache.hasBeenShown) {
    qtip.elements.tooltip.addClass("post-tooltip-loading");
    qtip.cache.hasBeenShown = true;
  }
};

PostTooltip.POST_SELECTOR = "*:not(.ui-sortable-handle) > .post-preview img";

// http://qtip2.com/options
PostTooltip.QTIP_OPTIONS = {
  style: "qtip-light post-tooltip",
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

    PostTooltip.lostFocus = false;
  });

  $(document).on("mouseleave.danbooru.postTooltip", PostTooltip.POST_SELECTOR, function (event) {
    PostTooltip.lostFocus = true;
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
  return PostTooltip.isTouching || Utility.meta("disable-post-tooltips") === "true";
};

PostTooltip.on_disable_tooltips = function (event) {
  event.preventDefault();
  $(event.target).parents(".qtip").qtip("hide");

  if (Utility.meta("current-user-id") === "") {
    Utility.notice('<a href="/session/new">Login</a> to disable tooltips permanently');
    return;
  }

  $.ajax("/users/" + Utility.meta("current-user-id") + ".json", {
    method: "PUT",
    data: { "user[disable_post_tooltips]": "true" },
  }).then(function() {
    Utility.notice("Tooltips disabled; check your account settings to re-enable.");
    location.reload();
  });
};

$(document).ready(PostTooltip.initialize);

export default PostTooltip
