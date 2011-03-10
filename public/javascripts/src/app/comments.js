(function() {
  Danbooru.Comment = {};
  
  Danbooru.Comment.initialize_all = function() {
    this.initialize_response_link();
    this.initialize_preview_button();
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
      $.ajax("/dtext/preview", {
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
})();

$(document).ready(function() {
  Danbooru.Comment.initialize_all();
});
