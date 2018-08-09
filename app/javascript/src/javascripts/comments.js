import Utility from './utility'
import Dtext from './dtext'

let Comment = {};

Comment.initialize_all = function() {
  if ($("#c-posts").length || $("#c-comments").length) {
    $(document).on("click", ".reply-link", Comment.quote);
    $(document).on("click", ".edit_comment_link", Comment.show_edit_form);
    $(document).on("click", ".expand-comment-response", Comment.show_new_comment_form);
    this.initialize_expand_links();
  }

  if ($("#c-posts").length && $("#a-show").length) {
    Comment.highlight_threshold_comments(Utility.meta("post-id"));
  }

  $(window).on("danbooru:index_for_post", (_event, post_id, current_comment_section, include_below_threshold) => {
    if (include_below_threshold) {
      $("#threshold-comments-notice-for-" + post_id).hide();
    } else {
      Comment.highlight_threshold_comments(post_id);
    }
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

Comment.initialize_expand_links = function() {
  $(".comment-section form").hide();
  $(".comment-section input.expand-comment-response").click(function(e) {
    var post_id = $(this).closest(".comment-section").data("post-id");
    $(this).hide();
    $(".comment-section[data-post-id=" + post_id + "] form").slideDown("fast");
    e.preventDefault();
  });
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

Comment.highlight_threshold_comments = function(post_id) {
  var threshold = parseInt(Utility.meta("user-comment-threshold"));
  var articles = $("article.comment[data-post-id=" + post_id + "]");
  articles.each(function(i, v) {
    var $comment = $(v);
    if (parseInt($comment.data("score")) < threshold) {
      $comment.addClass("below-threshold");
    }
  });
}

Comment.hide_threshold_comments = function(post_id) {
  var threshold = parseInt(Utility.meta("user-comment-threshold"));
  var articles = $("article.comment[data-post-id=" + post_id + "]");
  articles.each(function(i, v) {
    var $comment = $(v);
    if (parseInt($comment.data("score")) < threshold) {
      $comment.hide();
    }
  });
}

$(document).ready(function() {
  Comment.initialize_all();
});

export default Comment

