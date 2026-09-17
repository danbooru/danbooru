class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
      $(document).on("click.danbooru.comment", ".edit_comment_link", CommentComponent.showEditCommentForm);
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

  static showEditCommentForm(e) {
    $(this).closest("article.comment").find(".edit_comment").show();
    e.preventDefault();
  }
}

$(document).ready(CommentComponent.initialize);

export default CommentComponent;
