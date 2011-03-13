(function() {
  Danbooru.ForumPost = {};
  
  Danbooru.ForumPost.initialize_all = function() {
    $("#c-forum-topics #preview").hide();
    
    this.initialize_preview_link();
  }
  
  Danbooru.ForumPost.initialize_preview_link = function() {
    $("#c-forum-topics #preview a[name=toggle-preview]").click(function() {
      $("#preview").toggle();
      $("#dtext-help").toggle();
    });
    
    $("#c-forum-topics input[value=Preview]").click(function(e) {
      e.preventDefault();
      $.ajax({
        type: "post",
        url: "/dtext/preview",
        data: {
          body: $("#forum_post_body").val()
        },
        success: function(data) {
          $("#dtext-help").hide();
          $("#preview").show();
          $("#preview .content").html(data);
        }
      });
    });
  }
})();

$(document).ready(function() {
  Danbooru.ForumPost.initialize_all();
});
