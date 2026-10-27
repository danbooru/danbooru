class CommentComponent {
  static initialize() {
    if ($("#c-posts #a-show, #c-comments").length) {
      $(document).on("click.danbooru.comment", ".expand-comment-response", CommentComponent.showNewCommentForm);
      $(document).on("click.danbooru.comment", ".edit_comment_link", CommentComponent.showEditCommentForm);
      $(document).on("click.danbooru.comment", ".edit_comment button[name=cancel]", CommentComponent.hideCommentForm);
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

  static hideCommentForm(e) {
    let $form = $(e.target).closest("form");
    $form.hide();
    $form.closest("div.new-comment").find(".expand-comment-response").show();
  }
}

$(document).ready(CommentComponent.initialize);

export default CommentComponent;
