(function() {
  Danbooru.Comment = {};
  
  Danbooru.Comment.initialize_all = function() {
    $("div.dtext-preview").hide();
    this.initialize_response_link();
    this.initialize_preview_button();
    this.initialize_reply_links();
  }
  
  Danbooru.Comment.quote_message = function(data) {
    var stripped_body = data["body"].replace(/\[quote\](?:.|\n|\r)+?\[\/quote\](?:\r\n|\r|\n)*/gm, "");
    return "[quote]\n" + data["creator_name"] + " said:\n" + stripped_body + "\n[/quote]\n\n";
  }
  
  Danbooru.Comment.quote = function(e) {
    $.get(
      "/comments/" + $(e.target).data('comment-id') + ".json",
      function(data) {
        var $link = $(e.target);
        var $div = $link.closest("div.comments-for-post");
        var $textarea = $div.find("textarea")
        $textarea.val(Danbooru.Comment.quote_message(data));
        $div.find("a.expand-comment-response").trigger("click");
        $textarea.focus();
      }
    );
    e.preventDefault();
  }
  
  Danbooru.Comment.initialize_reply_links = function() {
    $(".reply-link").click(Danbooru.Comment.quote);
  }
  
  Danbooru.Comment.initialize_response_link = function() {
    $("a.expand-comment-response").click(function(e) {
      e.preventDefault();
      $(e.target).closest("div.new-comment").find("form").show();
      $(e.target).hide();
    });
    
    $("div.new-comment form").hide();
  }
  
  Danbooru.Comment.initialize_preview_button = function() {
    $("div.new-comment input[type=submit][value=Preview]").click(function(e) {
      e.preventDefault();
      $.ajax("/dtext_preview", {
        type: "post",
        data: {
          body: $(e.target).closest("form").find("textarea").val()
        },
        success: function(data) {
          $(e.target).closest("div.new-comment").find("div.comment-preview").show().html(data);
        }
      });
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
    })
  }
})();

$(document).ready(function() {
  Danbooru.Comment.initialize_all();
});
