import Utility from "../../javascript/src/javascripts/utility.js";

class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".edit_comment_link", CommentComponent.showEditForm);
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
      $(document).on("click.danbooru.comment", ".unhide-comment-link", CommentComponent.unhideComment);
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

  static showEditForm(e) {
    $(this).closest(".comment").find(".edit_comment").show();
    e.preventDefault();
  }

  static unhideComment(e) {
    let $comment = $(this).closest(".comment");
    $comment.find(".unhide-comment-link").hide();
    $comment.find(".body").show();
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
