import Notice from "./notice";
import { createTooltip } from "./utility";

class PostVotesTooltipComponent {
  // Trigger on the post score link; see PostVotesComponent.
  static TARGET_SELECTOR = "span.post-votes span.post-score > a";
  static SHOW_DELAY = 375;
  static HIDE_DELAY = 125;
  static DURATION = 250;
  static instance = null;

  static initialize() {
    PostVotesTooltipComponent.instance = createTooltip("post-votes-tooltip", {
      delay: [PostVotesTooltipComponent.SHOW_DELAY, PostVotesTooltipComponent.HIDE_DELAY],
      duration: PostVotesTooltipComponent.DURATION,
      target: PostVotesTooltipComponent.TARGET_SELECTOR,

      onShow: PostVotesTooltipComponent.onShow,
      onHide: PostVotesTooltipComponent.onHide,
    });
  }

  static async onShow(instance) {
    let $target = $(instance.reference);
    let $tooltip = $(instance.popper);
    let postId = $target.parents("[data-id]").data("id");

    try {
      $tooltip.addClass("tooltip-loading");

      instance._request = $.get(`/post_votes?search[post_id]=${postId}`, { variant: "tooltip" });
      let html = await instance._request;
      instance.setContent(html);

      $tooltip.removeClass("tooltip-loading");
    } catch (error) {
      if (error.status !== 0 && error.statusText !== "abort") {
        Notice.error(`Error displaying votes for post #${postId} (error: ${error.status} ${error.statusText})`);
      }
    }
  }

  static async onHide(instance) {
    if (instance._request?.state() === "pending") {
      instance._request.abort();
    }
  }
}

$(document).ready(PostVotesTooltipComponent.initialize);

export default PostVotesTooltipComponent;
