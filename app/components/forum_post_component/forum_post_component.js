import Utility from "../../javascript/src/javascripts/utility.js";

class ForumPostComponent {
  static initialize() {
    if ($("#c-forum-topics #a-show, #c-forum-posts #a-show").length) {
      $(document).on("click.danbooru.forum_post", ".edit_forum_post_link", ForumPostComponent.showEditPostForm);
      $(document).on("click.danbooru.forum_post", ".edit_forum_topic_link", ForumPostComponent.showEditTopicForm);
      $(document).on("click.danbooru.forum_post", "#new-response-link", ForumPostComponent.showNewForumPostForm);
      $(document).on("click.danbooru.forum_post", ".forum-post-copy-link", ForumPostComponent.copyLink);
    }
  }

  static showNewForumPostForm(e) {
    $("#topic-response").show();
    document.body.scrollIntoView(false);
    e.preventDefault();
  }

  static showEditPostForm(e) {
    $(this).closest(".forum-post").find(".edit_forum_post").show();
    e.preventDefault();
  }

  static showEditTopicForm(e) {
    $(this).closest(".forum-post").find(".edit_forum_topic").show();
    e.preventDefault();
  }

  static async copyLink(e) {
    let $forumPost = $(this).closest(".forum-post");
    let link = `forum #${$forumPost.data("id")}`;
    e.preventDefault();

    try {
      await navigator.clipboard.writeText(link);
      Utility.notice(`Copied ${link} to clipboard.`);
    } catch (error) {
      Utility.error("Couldn't copy link to clipboard");
    }
  }
}

$(document).ready(ForumPostComponent.initialize);

export default ForumPostComponent;
