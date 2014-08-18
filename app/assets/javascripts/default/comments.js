(function() {
  Danbooru.Comment = {};

  Danbooru.Comment.initialize_all = function() {
    if ($("#c-posts").length || $("#c-comments").length) {
      this.initialize_response_link();
      this.initialize_reply_links();
      this.initialize_expand_links();
      this.initialize_vote_links();

      if (!$("#a-edit").length) {
        this.initialize_edit_links();
      }
    }

    if ($("#c-posts").length && $("#a-show").length) {
      Danbooru.Comment.highlight_threshold_comments(Danbooru.meta("post-id"));
    }
  }

  Danbooru.Comment.quote_message = function(data) {
    var blocks = data["body"].match(/\[\/?quote\]|.|\n|\r/gm);
    var n = 0;
    var stripped_body = "";
    $.each(blocks, function(i, block) {
      if (block === "[quote]") {
        n += 1;
      } else if (block == "[/quote]") {
        n -= 1;
      } else if (n === 0) {
        stripped_body += block;
      }
    });
    return "[quote]\n" + data["creator_name"] + " said:\n\n" + stripped_body + "\n[/quote]\n\n";
  }

  Danbooru.Comment.quote = function(e) {
    $.get(
      "/comments/" + $(e.target).data('comment-id') + ".json",
      function(data) {
        var $link = $(e.target);
        var $div = $link.closest("div.comments-for-post").find(".new-comment");
        var $textarea = $div.find("textarea");
        var msg = Danbooru.Comment.quote_message(data);
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

  Danbooru.Comment.initialize_reply_links = function($parent) {
    $parent = $parent || $(document);
    $parent.find(".reply-link").click(Danbooru.Comment.quote);
  }

  Danbooru.Comment.initialize_expand_links = function() {
    $(".comment-section form").hide();
    $(".comment-section input.expand-comment-response").click(function(e) {
      var post_id = $(this).closest(".comment-section").data("post-id");
      $(this).hide();
      $(".comment-section[data-post-id=" + post_id + "] form").slideDown("fast");
      e.preventDefault();
    });
  }

  Danbooru.Comment.initialize_response_link = function() {
    $("a.expand-comment-response").click(function(e) {
      $(e.target).hide();
      var $form = $(e.target).closest("div.new-comment").find("form");
      $form.show();
      Danbooru.scroll_to($form);
      e.preventDefault();
    });

    $("div.new-comment form").hide();
  }

  Danbooru.Comment.initialize_edit_links = function($parent) {
    $parent = $parent || $(document);
    $parent.find(".edit_comment").hide();
    $parent.find(".edit_comment_link").click(function(e) {
      var link_id = $(this).attr("id");
      var comment_id = link_id.match(/^edit_comment_link_(\d+)$/)[1];
      $("#edit_comment_" + comment_id).fadeToggle("fast");
      e.preventDefault();
    });
  }

  Danbooru.Comment.highlight_threshold_comments = function(post_id) {
    var threshold = parseInt(Danbooru.meta("user-comment-threshold"));
    var articles = $("article.comment[data-post-id=" + post_id + "]");
    articles.each(function(i, v) {
      var $comment = $(v);
      if (parseInt($comment.data("score")) < threshold) {
        $comment.addClass("below-threshold");
      }
    });
  }

  Danbooru.Comment.hide_threshold_comments = function(post_id) {
    var threshold = parseInt(Danbooru.meta("user-comment-threshold"));
    var articles = $("article.comment[data-post-id=" + post_id + "]");
    articles.each(function(i, v) {
      var $comment = $(v);
      if (parseInt($comment.data("score")) < threshold) {
        $comment.hide();
      }
    });
  }

  Danbooru.Comment.initialize_vote_links = function($parent) {
    $parent = $parent || $(document);
    $parent.find(".unvote-comment-link").hide();
  }
})();

$(document).ready(function() {
  Danbooru.Comment.initialize_all();
});
