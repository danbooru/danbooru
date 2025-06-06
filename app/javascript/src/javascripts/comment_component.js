import Utility from "./utility";

class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
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
}

$(document).ready(CommentComponent.initialize);

export default CommentComponent;
