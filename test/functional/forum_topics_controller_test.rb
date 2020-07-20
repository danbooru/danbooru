require 'test_helper'

class ForumTopicsControllerTest < ActionDispatch::IntegrationTest
  def default_search_order(items)
    ->{ items.each { |val| val.reload }.sort_by(&:updated_at).reverse }
  end

  context "The forum topics controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)
      @mod = create(:moderator_user, name: "okuu")

      as(@user) do
        @forum_topic = create(:forum_topic, creator: @user, title: "my forum topic", original_post: build(:forum_post, creator: @user, topic: @forum_topic, body: "xxx"))
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
        as(@user) do
          @sticky_topic = create(:forum_topic, is_sticky: true, creator: @user, original_post: build(:forum_post))
          @other_topic = create(:forum_topic, creator: @user, original_post: build(:forum_post))
        end
        @mod_topic = as(@mod) { create(:forum_topic, creator: @mod, min_level: User::Levels::MODERATOR, original_post: build(:forum_post)) }
        create(:bulk_update_request, forum_topic: @forum_topic)
        create(:tag_alias, forum_topic: @other_topic)
      end

      should "list public forum topics for members" do
        get forum_topics_path

        assert_response :success
        assert_select "a.forum-post-link", count: 1, text: @sticky_topic.title
        assert_select "a.forum-post-link", count: 1, text: @other_topic.title
      end

      should "not list stickied topics first for JSON responses" do
        get forum_topics_path, params: {format: :json}
        forum_topics = JSON.parse(response.body)
        assert_equal(default_search_order([@other_topic, @sticky_topic, @forum_topic]).call.map(&:id), forum_topics.map {|t| t["id"]})
      end

      should "render for atom feed" do
        get forum_topics_path, params: {:format => :atom}
        assert_response :success
      end

      should "render for a sitemap" do
        get forum_topics_path(format: :sitemap)
        assert_response :success
        assert_equal(ForumTopic.visible(User.anonymous).count, response.parsed_body.css("urlset url loc").size)
      end

      context "with private topics" do
        should "not show private topics to unprivileged users" do
          as(@user) { @other_topic.update!(min_level: User::Levels::MODERATOR) }
          get forum_topics_path

          assert_response :success
          assert_select "a.forum-post-link", count: 1, text: @sticky_topic.title
          assert_select "a.forum-post-link", count: 0, text: @other_topic.title
        end

        should "show private topics to privileged users" do
          as(@user) { @other_topic.update!(min_level: User::Levels::MODERATOR) }
          get_auth forum_topics_path, @mod

          assert_response :success
          assert_select "a.forum-post-link", count: 1, text: @sticky_topic.title
          assert_select "a.forum-post-link", count: 1, text: @other_topic.title
        end
      end

      context "with search conditions" do
        context "as a user" do
          setup do
            CurrentUser.user = @user
          end

          should respond_to_search({}).with { default_search_order([@sticky_topic, @other_topic, @forum_topic]) }
          should respond_to_search(order: "id").with { [@other_topic, @sticky_topic, @forum_topic] }
          should respond_to_search(title_matches: "forum").with { @forum_topic }
          should respond_to_search(title_matches: "bababa").with { [] }
          should respond_to_search(is_sticky: "true").with { @sticky_topic }

          context "using includes" do
            should respond_to_search(forum_posts: {body_matches: "xxx"}).with { @forum_topic }
            should respond_to_search(has_bulk_update_requests: "true").with { @forum_topic }
            should respond_to_search(has_tag_aliases: "true").with { @other_topic }
            should respond_to_search(creator_name: "okuu").with { [] }
          end
        end

        context "as a moderator" do
          setup do
            CurrentUser.user = @mod
          end

          should respond_to_search({}).with { default_search_order([@sticky_topic, @other_topic, @mod_topic, @forum_topic]) }

          context "using includes" do
            should respond_to_search(creator_name: "okuu").with { @mod_topic }
          end
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
        as(@user) do
          @post = create(:forum_post, topic: @forum_topic)
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
