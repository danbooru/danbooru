import CurrentUser from './current_user';
import Notice from './notice';
import { createTooltip } from './utility';
import { hideAll } from 'tippy.js';

let TagTooltip = {};

TagTooltip.SELECTOR = "a.search-tag, a[data-tag-name]";
TagTooltip.SHOW_DELAY = 500;
TagTooltip.HIDE_DELAY = 125;
TagTooltip.DURATION = 250;
TagTooltip.PRELOAD_TIMEOUT = 500;

TagTooltip.initialize = function () {
  if (TagTooltip.disabled()) {
    return;
  }

  let options = {
    delay: [TagTooltip.SHOW_DELAY, TagTooltip.HIDE_DELAY],
    duration: TagTooltip.DURATION,
    touch: false,

    onTrigger: TagTooltip.on_trigger,
    onShow: TagTooltip.on_show,
    onHide: TagTooltip.on_hide,
  }

  createTooltip("tag-tooltip", {
    target: TagTooltip.SELECTOR,
    // A tag link may be inside another tooltip. In that case, append inside that ancestor tooltip's .tippy-box
    // instead of the default #tooltips container.
    appendTo: reference => reference.closest(".tippy-box") ?? document.querySelector("#tooltips"),
    ...options
  });
};

// @return {Boolean} true if this tooltip is inside another tooltip
TagTooltip.is_nested = function ($target) {
  return $target.closest("[data-tippy-root]").length > 0;
};

TagTooltip.on_trigger = function (instance) {
  instance.reference.removeAttribute("title");
};

TagTooltip.on_show = async function (instance) {
  let $target = $(instance.reference);
  let $tooltip = $(instance.popper);

  // Hide other open tooltips, unless this tooltip is nested inside another tooltip
  if (!TagTooltip.is_nested($target)) {
    hideAll({ exclude: instance });
  }

  // skip if tooltip has already been rendered.
  if ($tooltip.has(".tag-tooltip").length) {
    return;
  }

  let tag_name = $target.attr("data-tag-name") || $target.closest("[data-tag-name]").data("tag-name");

  // A numeric tag name (e.g. "1") is ambiguous with a tag id, so prefix it with a "~" to force the
  // controller to look it up by name instead (see Tag.find_by_id_or_name).
  let tag_id = /^\d+$/.test(tag_name) ? `~${tag_name}` : tag_name;

  try {
    $tooltip.addClass("tooltip-loading");

    instance._request = $.get(`/tags/${encodeURIComponent(tag_id)}`, { variant: "tooltip" });
    let html = await instance._request;

    // Wait for the embedded thumbnail (if any) to finish loading before revealing the tooltip, so it
    // doesn't pop in a moment after the tooltip itself appears.
    await TagTooltip.preload_image(html);

    instance.setContent(html);
    $tooltip.removeClass("tooltip-loading");
  } catch (error) {
    if (error.status !== 0 && error.statusText !== "abort") {
      Notice.error(`Error displaying tooltip for tag ${tag_name} (error: ${error.status} ${error.statusText})`);
    }
  }
};

// @param {String} html - The tooltip's HTML, not yet attached to the document.
// @return {Promise} Resolves once the tooltip's embed thumbnail (if any) has loaded, or after
//   PRELOAD_TIMEOUT elapses, whichever comes first.
TagTooltip.preload_image = function (html) {
  let src = $(html).find(".tag-tooltip-embed img").attr("src");
  if (!src) {
    return Promise.resolve();
  }

  let image = Object.assign(new Image(), { src });
  return Promise.race([
    image.decode().catch(() => null),
    new Promise(resolve => setTimeout(resolve, TagTooltip.PRELOAD_TIMEOUT)),
  ]);
};

TagTooltip.on_hide = function (instance) {
  if (instance._request?.state() === "pending") {
    instance._request.abort();
  }
}

TagTooltip.disabled = function (event) {
  return CurrentUser.data("disable-post-tooltips");
};

$(document).ready(TagTooltip.initialize);

export default TagTooltip
