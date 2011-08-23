(function() {
  Danbooru.ForumPost = {};
  
  Danbooru.ForumPost.initialize_all = function() {
    $("#c-forum-topics #preview").hide();
    
    this.initialize_preview_link();
    this.initialize_last_forum_read_at();
  }
  
  Danbooru.ForumPost.initialize_last_forum_read_at = function() {
    var last_forum_read_at = Date.parse(Danbooru.meta("last-forum-read-at"));
    
    $("#c-forum-topics #a-index time").each(function(i, x) {
      var $x = $(x);
      var $date = Date.parse($x.attr("datetime"));
      if (Date.parse($x.attr("datetime")) > last_forum_read_at) {
        $x.closest("tr").addClass("new-topic");
      }
    });
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
