let ForumPost = {};

ForumPost.initialize_all = function() {
  if ($("#c-forum-topics #a-show,#c-forum-posts #a-show").length) {
    this.initialize_edit_links();
  }
}

ForumPost.initialize_edit_links = function() {
  $(document).on("click.danbooru", ".edit_forum_post_link", function(e) {
    let $form = $(this).parents("article.forum-post").find("form.edit_forum_post");
    $form.fadeToggle("fast");
    e.preventDefault();
  });

  $(document).on("click.danbooru", ".edit_forum_topic_link", function(e) {
    let $form = $(this).parents("article.forum-post").find("form.edit_forum_topic");
    $form.fadeToggle("fast");
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
