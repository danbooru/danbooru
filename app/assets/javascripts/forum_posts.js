(function() {
  Danbooru.ForumPost = {};
  
  Danbooru.ForumPost.initialize_all = function() {
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
})();

$(document).ready(function() {
  Danbooru.ForumPost.initialize_all();
});
