import Utility from './utility'

let ForumPost = {};

ForumPost.initialize_all = function() {
  if ($("#c-forum-topics #a-show,#c-forum-posts #a-show").length) {
    this.initialize_edit_links();

    Utility.keydown("e", "edit", function(e) {
      $(".edit_forum_topic_link")[0].click();
    });

    Utility.keydown("shift+d", "delete", function(e) {
      $("#forum-topic-delete a")[0].click();
    });
  }

  if ($("#c-forum-topics").length) {
    Utility.keydown("shift+r", "mark_all_as_read", function(e) {
      $("#forum-topic-mark-all-as-read a")[0].click();
    });
  }
}

ForumPost.initialize_edit_links = function() {
  $(".edit_forum_post, .edit_forum_topic").hide();

  $(".edit_forum_post_link").click(function(e) {
    var link_id = $(this).attr("id");
    var forum_post_id = link_id.match(/^edit_forum_post_link_(\d+)$/)[1];
    $("#edit_forum_post_" + forum_post_id).fadeToggle("fast");
    e.preventDefault();
  });

  $(".edit_forum_topic_link").click(function(e) {
    var link_id = $(this).attr("id");
    var forum_topic_id = link_id.match(/^edit_forum_topic_link_(\d+)$/)[1];
    $("#edit_forum_topic_" + forum_topic_id).fadeToggle("fast");
    e.preventDefault();
  });
}

$(document).ready(function() {
  ForumPost.initialize_all();
});

export default ForumPost
