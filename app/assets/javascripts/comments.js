(function() {
  Danbooru.Comment = {};
  
  Danbooru.Comment.initialize_all = function() {
    $("div.dtext-preview").hide();
    this.initialize_response_link();
    this.initialize_preview_button();
    this.hide_threshold_comments();
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
    console.log("articles=%o", articles);
    articles.each(function(i, v) {
      var $comment = $(v);
      console.log("testing %o", $comment);
      if (parseInt($comment.data("score")) < threshold) {
        $comment.addClass("below-threshold");
      }
    })
  }
  
  Danbooru.Comment.hide_threshold_comments = function(post_id) {
    var threshold = parseInt(Danbooru.meta("user-comment-threshold"));
    var articles = null;
    
    if (post_id) {
      articles = $("article.comment[data-post-id=" + post_id + "]");
    } else {
      articles = $("article.comment");
    }
    
    articles.each(function(i, v) {
      var $comment = $(v);
      if (parseInt($comment.data("score")) < threshold) {
        $comment.hide();
      }
    });
  }
})();

$(document).ready(function() {
  Danbooru.Comment.initialize_all();
});
