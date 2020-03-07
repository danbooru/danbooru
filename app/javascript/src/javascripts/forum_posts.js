let ForumPost = {};

ForumPost.initialize_all = function() {
  if ($("#c-forum-topics #a-show,#c-forum-posts #a-show").length) {
    this.initialize_edit_links();
  }
}

ForumPost.initialize_edit_links = function() {
  $(".edit_forum_post_link").on("click.danbooru", function(e) {
    var link_id = $(this).attr("id");
    var forum_post_id = link_id.match(/^edit_forum_post_link_(\d+)$/)[1];
    $("#edit_forum_post_" + forum_post_id).fadeToggle("fast");
    e.preventDefault();
  });

  $(".edit_forum_topic_link").on("click.danbooru", function(e) {
    var link_id = $(this).attr("id");
    var forum_topic_id = link_id.match(/^edit_forum_topic_link_(\d+)$/)[1];
    $("#edit_forum_topic_" + forum_topic_id).fadeToggle("fast");
    e.preventDefault();
  });

  $(document).on("click.danbooru", "#c-forum-topics #a-show #new-response-link", function (e) {
    $("#topic-response").show();
    document.body.scrollIntoView(false);
    e.preventDefault();
  });
}

$(document).ready(function() {
  ForumPost.initialize_all();
});

export default ForumPost
