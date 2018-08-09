import Utility from './utility'
import Dtext from './dtext'

let Comment = {};

Comment.initialize_all = function() {
  if ($("#c-posts").length || $("#c-comments").length) {
    $(document).on("click", ".reply-link", Comment.quote);
    $(document).on("click", ".edit_comment_link", Comment.show_edit_form);
    $(document).on("click", ".expand-comment-response", Comment.show_new_comment_form);
  }

  $(window).on("danbooru:index_for_post", (_event, post_id, current_comment_section) => {
    $("#threshold-comments-notice-for-" + post_id).hide();
    Dtext.initialize_expandables(current_comment_section);
  });
}

Comment.quote = function(e) {
  $.get(
    "/comments/" + $(e.target).data('comment-id') + ".json",
    function(data) {
      var $link = $(e.target);
      var $div = $link.closest("div.comments-for-post").find(".new-comment");
      var $textarea = $div.find("textarea");
      var msg = data.quoted_response;
      if ($textarea.val().length > 0) {
        msg = $textarea.val() + "\n\n" + msg;
      }
      $textarea.val(msg);
      $div.find("a.expand-comment-response").trigger("click");
      $textarea.selectEnd();
    }
  );
  e.preventDefault();
}

Comment.show_new_comment_form = function(e) {
  $(e.target).hide();
  var $form = $(e.target).closest("div.new-comment").find("form");
  $form.show();
  Utility.scroll_to($form);
  e.preventDefault();
}

Comment.show_edit_form = function(e) {
  $(this).closest(".comment").find(".edit_comment").show();
  e.preventDefault();
}

$(document).ready(function() {
  Comment.initialize_all();
});

export default Comment

