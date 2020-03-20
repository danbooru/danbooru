require 'test_helper'

class ForumTopicsControllerTest < ActionDispatch::IntegrationTest
  context "The forum topics controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)
      @mod = create(:moderator_user)

      as(@user) do
        @forum_topic = create(:forum_topic, creator: @user, title: "my forum topic")
        @forum_post = create(:forum_post, creator: @user, topic: @forum_topic, body: "xxx")
      end
    end

    context "for a level restricted topic" do
      setup do
        as(@mod) do
          @forum_topic.update(min_level: User::Levels::MODERATOR)
        end
      end

      should "not allow users to see the topic" do
        get_auth forum_topic_path(@forum_topic), @user
        assert_response 403
      end

      should "not bump the forum for users without access" do
        @gold_user = create(:gold_user)

        # An open topic should bump...
        @open_topic = as(@gold_user) { create(:forum_topic, creator: @gold_user) }
        @gold_user.reload
        as(@gold_user) do
          assert(@gold_user.has_forum_been_updated?)
        end

        # Marking it as read should clear it...
        as(@gold_user) do
          post_auth mark_all_as_read_forum_topics_path, @gold_user
        end
        @gold_user.reload
        assert_redirected_to(forum_topics_path)
        as(@gold_user) do
          assert(!@gold_user.has_forum_been_updated?)
        end

        # Then adding an unread private topic should not bump.
        as(@mod) { create(:forum_post, topic: @forum_topic, creator: @mod) }
        @gold_user.reload
        as(@gold_user) do
          assert_equal(false, @gold_user.has_forum_been_updated?)
        end
      end
    end

    context "show action" do
      should "render" do
        get forum_topic_path(@forum_topic)
        assert_response :success
      end

      should "record a topic visit for html requests" do
        get_auth forum_topic_path(@forum_topic), @user
        @user.reload
        assert_not_nil(@user.last_forum_read_at)
      end

      should "not record a topic visit for non-html requests" do
        get_auth forum_topic_path(@forum_topic), @user, params: {format: :json}
        @user.reload
        assert_nil(@user.last_forum_read_at)
      end

      should "render for atom feed" do
        get forum_topic_path(@forum_topic), params: {:format => :atom}
        assert_response :success
      end

      should "raise an error if the user doesn't have permission to view the topic" do
        as(@user) { @forum_topic.update(min_level: User::Levels::ADMIN) }
        get_auth forum_topic_path(@forum_topic), @user

        assert_response 403
      end
    end

    context "index action" do
      setup do
        as_user do
          @topic1 = create(:forum_topic, is_sticky: true, creator: @user)
          @topic2 = create(:forum_topic, creator: @user)
          @post1 = create(:forum_post, topic: @topic1, creator: @user, body: "xxx")
          @post2 = create(:forum_post, topic: @topic2, creator: @user, body: "xxx")
        end
      end

      should "list public forum topics for members" do
        get forum_topics_path

        assert_response :success
        assert_select "a.forum-post-link", count: 1, text: @topic1.title
        assert_select "a.forum-post-link", count: 1, text: @topic2.title
      end

      should "not list stickied topics first for JSON responses" do
        get forum_topics_path, params: {format: :json}
        forum_topics = JSON.parse(response.body)
        assert_equal([@topic2.id, @topic1.id, @forum_topic.id], forum_topics.map {|t| t["id"]})
      end

      should "render for atom feed" do
        get forum_topics_path, params: {:format => :atom}
        assert_response :success
      end

      context "with private topics" do
        should "not show private topics to unprivileged users" do
          as(@user) { @topic2.update!(min_level: User::Levels::MODERATOR) }
          get forum_topics_path

          assert_response :success
          assert_select "a.forum-post-link", count: 1, text: @topic1.title
          assert_select "a.forum-post-link", count: 0, text: @topic2.title
        end

        should "show private topics to privileged users" do
          as(@user) { @topic2.update!(min_level: User::Levels::MODERATOR) }
          get_auth forum_topics_path, @mod

          assert_response :success
          assert_select "a.forum-post-link", count: 1, text: @topic1.title
          assert_select "a.forum-post-link", count: 1, text: @topic2.title
        end
      end

      context "with search conditions" do
        should "list all matching forum topics" do
          get forum_topics_path, params: {:search => {:title_matches => "forum"}}
          assert_response :success
          assert_select "a.forum-post-link", @forum_topic.title
          assert_select "a.forum-post-link", count: 0, text: @topic1.title
          assert_select "a.forum-post-link", count: 0, text: @topic2.title
        end

        should "list nothing for when the search matches nothing" do
          get forum_topics_path, params: {:search => {:title_matches => "bababa"}}
          assert_response :success
          assert_select "a.forum-post-link", count: 0, text: @forum_topic.title
          assert_select "a.forum-post-link", count: 0, text: @topic1.title
          assert_select "a.forum-post-link", count: 0, text: @topic2.title
        end
      end

      context "when listing topics" do
        should "always show topics as read for anonymous users" do
          get forum_topics_path
          assert_select 'tr[data-is-read="false"]', count: 0
        end

        should "show topics as read after viewing them" do
          get_auth forum_topics_path, @user
          assert_response :success
          assert_select 'tr[data-is-read="false"]', count: 3

          get_auth forum_topic_path(@forum_topic.id), @user
          assert_response :success

          get_auth forum_topics_path, @user
          assert_response :success
        end

        should "show topics as read after marking all as read" do
          get_auth forum_topics_path, @user
          assert_response :success
          assert_select 'tr[data-is-read="false"]', count: 3

          post_auth mark_all_as_read_forum_topics_path, @user
          assert_response 302

          get_auth forum_topics_path, @user
          assert_response :success
          assert_select 'tr[data-is-read="false"]', count: 0
        end

        should "show topics on page 2 as read after marking all as read" do
          get_auth forum_topics_path(page: 2, limit: 1), @user
          assert_response :success
          assert_select 'tr[data-is-read="false"]', count: 1

          post_auth mark_all_as_read_forum_topics_path, @user
          assert_response 302

          get_auth forum_topics_path(page: 2, limit: 1), @user
          assert_response :success
          assert_select 'tr[data-is-read="false"]', count: 0
        end
      end
    end

    context "edit action" do
      should "render if the editor is the creator of the topic" do
        get_auth edit_forum_topic_path(@forum_topic), @user
        assert_response :success
      end

      should "render if the editor is a moderator" do
        get_auth edit_forum_topic_path(@forum_topic), @mod
        assert_response :success
      end

      should "fail if the editor is not the creator of the topic and is not a moderator" do
        get_auth edit_forum_topic_path(@forum_topic), @other_user
        assert_response(403)
      end
    end

    context "new action" do
      should "render" do
        get_auth new_forum_topic_path, @user
        assert_response :success
      end
    end

    context "create action" do
      should "create a new forum topic and post" do
        assert_difference(["ForumPost.count", "ForumTopic.count"], 1) do
          post_auth forum_topics_path, @user, params: { forum_topic: { title: "bababa", original_post_attributes: { body: "xaxaxa" }}}
        end

        forum_topic = ForumTopic.last
        assert_redirected_to(forum_topic_path(forum_topic))
      end
    end

    context "update action" do
      should "allow mods to lock forum topics" do
        put_auth forum_topic_path(@forum_topic), @mod, params: { forum_topic: { is_locked: true }}

        assert_redirected_to forum_topic_path(@forum_topic)
        assert_equal(true, @forum_topic.reload.is_locked)
      end

      should "allow users to update their own topics" do
        put_auth forum_topic_path(@forum_topic), @user, params: { forum_topic: { title: "test" }}

        assert_redirected_to forum_topic_path(@forum_topic)
        assert_equal("test", @forum_topic.reload.title)
      end

      should "not allow users to update locked topics" do
        as(@mod) { @forum_topic.update!(is_locked: true) }
        put_auth forum_topic_path(@forum_topic), @user, params: { forum_topic: { title: "test" }}

        assert_response 403
        assert_not_equal("test", @forum_topic.reload.title)
      end

      should "allow mods to update locked topics" do
        as(@mod) { @forum_topic.update!(is_locked: true) }
        put_auth forum_topic_path(@forum_topic), @mod, params: { forum_topic: { title: "test" }}

        assert_redirected_to forum_topic_path(@forum_topic)
        assert_equal("test", @forum_topic.reload.title)
      end
    end

    context "destroy action" do
      setup do
        as_user do
          @post = create(:forum_post, :topic_id => @forum_topic.id)
        end
      end

      should "destroy the topic and any associated posts" do
        delete_auth forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert(@forum_topic.is_deleted?)
      end
    end

    context "undelete action" do
      setup do
        as(@mod) do
          @forum_topic.update(is_deleted: true)
        end
      end

      should "restore the topic" do
        post_auth undelete_forum_topic_path(@forum_topic), @mod
        assert_redirected_to(forum_topic_path(@forum_topic))
        @forum_topic.reload
        assert(!@forum_topic.is_deleted?)
      end
    end
  end
end
