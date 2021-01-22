import Utility from "../../javascript/src/javascripts/utility.js";

class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".edit_comment_link", CommentComponent.showEditForm);
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
      $(document).on("click.danbooru.comment", ".unhide-comment-link", CommentComponent.unhideComment);
      $(document).on("click.danbooru.comment", ".comment-copy-link", CommentComponent.copyLink);
    }
  }

  static showNewCommentForm(e) {
    $(e.target).hide();
    var $form = $(e.target).closest("div.new-comment").find("form");
    $form.show();
    $form[0].scrollIntoView(false);
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

  static async copyLink(e) {
    let $comment = $(this).closest(".comment");
    let link = `comment #${$comment.data("id")}`;
    e.preventDefault();

    try {
      await navigator.clipboard.writeText(link);
      Utility.notice(`Copied ${link} to clipboard.`);
    } catch (error) {
      Utility.error("Couldn't copy link to clipboard");
    }
  }
}

$(document).ready(CommentComponent.initialize);

export default CommentComponent;
