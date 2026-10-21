class ForumPostComponent {
  static initialize() {
    if ($("#c-forum-topics #a-show, #c-forum-posts #a-show").length) {
      $(document).on("click.danbooru.forum_post", ".edit_forum_post_link", ForumPostComponent.showEditPostForm);
      $(document).on("click.danbooru.forum_post", ".edit_forum_topic_link", ForumPostComponent.showEditTopicForm);
      $(document).on("click.danbooru.forum_post", "#new-response-link", ForumPostComponent.showNewForumPostForm);
      $(document).on("click.danbooru.forum_post", "#topic-response button[name=cancel]", ForumPostComponent.hideNewForumPostForm);
      $(document).on("click.danbooru.forum_post", ".edit_forum_post button[name=cancel], .edit_forum_topic button[name=cancel]", ForumPostComponent.hideEditForm);
    }
  }

  static showNewForumPostForm(e) {
    $("#topic-response").show();
    $("#forum_post_body").get(0).scrollIntoView(false);
    $("#forum_post_body").selectEnd();
    e.preventDefault();
  }

  static hideNewForumPostForm() {
    $("#topic-response").hide();
  }

  static showEditPostForm(e) {
    $(this).closest(".forum-post").find(".edit_forum_post").show();
    e.preventDefault();
  }

  static showEditTopicForm(e) {
    $(this).closest(".forum-post").find(".edit_forum_topic").show();
    e.preventDefault();
  }

  static hideEditForm(e) {
    $(e.target).closest("form").hide();
  }
}

$(document).ready(ForumPostComponent.initialize);

export default ForumPostComponent;
