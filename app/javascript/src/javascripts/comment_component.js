import Utility from "./utility";

class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
      $(document).on("click.danbooru.comment", ".comment-copy-id", CommentComponent.copyID);
      $(document).on("click.danbooru.comment", ".comment-copy-link", CommentComponent.copyLink);
    }
  }

  static showNewCommentForm(e) {
    $(e.target).hide();
    var $form = $(e.target).closest("div.new-comment").find("form");
    $form.show();
    $form[0].scrollIntoView(false);
    $form.find("textarea").selectEnd();
    e.preventDefault();
  }

  static async copyID(e) {
    let id = $(this).closest(".comment").data("id");
    let link = `comment #${id}`;
    Utility.copyToClipboard(link);
    e.preventDefault();
  }

  static async copyLink(e) {
    let id = $(this).closest(".comment").data("id");
    let link = `${window.location.origin}/comments/${id}`;
    Utility.copyToClipboard(link);
    e.preventDefault();
  }
}

$(document).ready(CommentComponent.initialize);

export default CommentComponent;
