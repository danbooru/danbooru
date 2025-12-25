import Notice from "./notice";
import { createTooltip } from "./utility";
import { hideAll } from 'tippy.js';

class FavoritesTooltipComponent {
  // Trigger on the post favcount link.
  static TARGET_SELECTOR = "span.post-favcount a";
  static SHOW_DELAY = 125;
  static HIDE_DELAY = 125;
  static DURATION = 250;
  static instance = null;

  static initialize() {
    if ($(FavoritesTooltipComponent.TARGET_SELECTOR).length === 0) {
      return;
    }

    FavoritesTooltipComponent.instance = createTooltip("favorites-tooltip", {
      delay: [FavoritesTooltipComponent.SHOW_DELAY, FavoritesTooltipComponent.HIDE_DELAY],
      duration: FavoritesTooltipComponent.DURATION,
      target: FavoritesTooltipComponent.TARGET_SELECTOR,

      onShow: FavoritesTooltipComponent.onShow,
      onHide: FavoritesTooltipComponent.onHide,
    });
  }

  static async onShow(instance) {
    let $target = $(instance.reference);
    let $tooltip = $(instance.popper);
    let postId = $target.parents("[data-id]").data("id");

    hideAll({ exclude: instance });

    try {
      $tooltip.addClass("tooltip-loading");

      instance._request = $.get(`/posts/${postId}/favorites?variant=tooltip`);
      let html = await instance._request;
      instance.setContent(html);

      $tooltip.removeClass("tooltip-loading");
    } catch (error) {
      if (error.status !== 0 && error.statusText !== "abort") {
        Notice.error(`Error displaying favorites for post #${postId} (error: ${error.status} ${error.statusText})`);
      }
    }
  }

  static async onHide(instance) {
    if (instance._request?.state() === "pending") {
      instance._request.abort();
    }
  }
}

$(document).ready(FavoritesTooltipComponent.initialize);

export default FavoritesTooltipComponent;
