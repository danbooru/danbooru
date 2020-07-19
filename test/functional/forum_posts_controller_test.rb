require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest
  context "The forum posts controller" do
    setup do
      @user = create(:user, id: 999)
      @other_user = create(:user)
      @mod = create(:moderator_user, name: "okuu")
      @forum_topic = as(@user) { create(:forum_topic, title: "my forum topic", creator: @user) }
      @forum_post = as(@user) { create(:forum_post, creator: @user, topic: @forum_topic, body: "alias xxx -> yyy") }
    end

    context "with votes" do
      setup do
        as(@user) do
          @bulk_update_request = create(:bulk_update_request, forum_post: @forum_post)
          @vote = create(:forum_post_vote, forum_post: @forum_post, score: 1)
          @forum_post.reload
        end
      end

      should "render the vote links" do
        get_auth forum_topic_path(@forum_topic), @mod
        assert_response :success
        assert_select "a[title='Vote up']"
      end

      should "render existing votes" do
        get_auth forum_topic_path(@forum_topic), @mod
        assert_response :success
        assert_select "li.vote-score-up"
      end

      context "after the BUR is rejected" do
        setup do
          as(@mod) do
            @bulk_update_request.reject!
          end
          get_auth forum_topic_path(@forum_topic), @mod
        end

        should "hide the vote links" do
          assert_select "a[title='Vote up']", false
          assert_response :success
        end

        should "still render existing votes" do
          assert_select "li.vote-score-up"
          assert_response :success
        end
      end
    end

    context "index action" do
      setup do
        @admin = create(:admin_user)
        @other_forum = as(@user) { create(:forum_post, body: "[[test]]", topic: build(:forum_topic, title: "my topic", category_id: 1)) }
        @mod_forum = as(@mod) { create(:forum_post, creator: @mod, topic: build(:forum_topic, min_level: User::Levels::MODERATOR)) }
        @admin_forum = as(@admin) { create(:forum_post, creator: @admin, topic: build(:forum_topic, min_level: User::Levels::ADMIN)) }
        @unrelated_forum = as (@user) { create(:forum_post, is_deleted: true) }
        as (@user) { create(:forum_post_vote, forum_post: @forum_post) }
        create(:bulk_update_request, forum_post: @other_forum)
      end

      context "as a user" do
        setup do
          CurrentUser.user = @user
        end

        should "render" do
          get_auth comment_votes_path, @user
          assert_response :success
        end

        should respond_to_search({}).with { [@unrelated_forum, @other_forum, @forum_post] }
        should respond_to_search(body_matches: "xxx").with { @forum_post }
        should respond_to_search(body_matches: "bababa").with { [] }
        should respond_to_search(is_deleted: "true").with { @unrelated_forum }

        context "using includes" do
          should respond_to_search(topic: {title_matches: "my forum topic"}).with { @forum_post }
          should respond_to_search(topic: {category_id: 1}).with { @other_forum }
          should respond_to_search(has_bulk_update_request: "true").with { @other_forum }
          should respond_to_search(has_votes: "true").with { @forum_post }
          should respond_to_search(has_dtext_links: "true").with { @other_forum }
          should respond_to_search(creator_id: 999).with { @forum_post }
          should respond_to_search(creator: {name: "okuu"}).with { [] }
        end
      end

      context "as a moderator" do
        setup do
          CurrentUser.user = @mod
        end

        should respond_to_search({}).with { [@unrelated_forum, @mod_forum, @other_forum, @forum_post] }

        context "using includes" do
          should respond_to_search(creator: {name: "okuu"}).with { @mod_forum }
        end
      end

      context "as an admin" do
        setup do
          CurrentUser.user = @admin
        end

        should respond_to_search({}).with { [@unrelated_forum, @admin_forum, @mod_forum, @other_forum, @forum_post] }
      end
    end

    context "show action" do
      should "raise an error if the user doesn't have permission to view the topic" do
        as(@user) { @forum_post.topic.update(min_level: User::Levels::ADMIN) }
        get_auth forum_post_path(@forum_post), @user

        assert_response 403
      end

      should "redirect to the forum topic" do
        get forum_post_path(@forum_post)
        assert_redirected_to forum_topic_path(@forum_post.topic, anchor: "forum_post_#{@forum_post.id}")
      end
    end

    context "edit action" do
      should "render if the editor is the creator of the topic" do
        get_auth edit_forum_post_path(@forum_post), @user
        assert_response :success
      end

      should "render if the editor is a moderator" do
        get_auth edit_forum_post_path(@forum_post), @mod
        assert_response :success
      end

      should "fail if the editor is not the creator of the topic and is not a moderator" do
        get_auth edit_forum_post_path(@forum_post), @other_user
        assert_response(403)
      end

      should "fail if the topic is private and the editor is unauthorized" do
        as(@user) { @forum_post.topic.update(min_level: User::Levels::ADMIN) }
        get_auth edit_forum_post_path(@forum_post), @user
        assert_response(403)
      end
    end

    context "new action" do
      should "render" do
        get_auth new_forum_post_path, @user, params: {:topic_id => @forum_topic.id}
        assert_response :success
      end

      should "not allow unauthorized users to quote posts in private forum topics" do
        as(@user) { @forum_post.topic.update(min_level: User::Levels::ADMIN) }
        get_auth new_forum_post_path, @user, params: { post_id: @forum_post.id }

        assert_response 403
      end
    end

    context "create action" do
      should "create a new forum post" do
        assert_difference("ForumPost.count", 1) do
          post_auth forum_posts_path, @user, params: {:forum_post => {:body => "xaxaxa", :topic_id => @forum_topic.id}}
          assert_redirected_to(forum_topic_path(@forum_topic))
        end
      end

      should "not allow unauthorized users to create posts in private topics" do
        as(@user) { @forum_post.topic.update!(min_level: User::Levels::ADMIN) }

        post_auth forum_posts_path, @user, params: { forum_post: { body: "xaxaxa", topic_id: @forum_topic.id }}
        assert_response 403
      end

      should "not allow non-moderators to create posts in locked topics" do
        as(@user) { @forum_post.topic.update!(is_locked: true) }

        post_auth forum_posts_path, @user, params: { forum_post: { body: "xaxaxa", topic_id: @forum_topic.id }}
        assert_response 403
      end

      should "allow moderators to create posts in locked topics" do
        as(@user) { @forum_post.topic.update!(is_locked: true) }

        post_auth forum_posts_path, @mod, params: { forum_post: { body: "xaxaxa", topic_id: @forum_topic.id }}
        assert_redirected_to(forum_topic_path(@forum_topic))
      end
    end

    context "update action" do
      should "allow users to update their own posts" do
        put_auth forum_post_path(@forum_post), @user, params: { forum_post: { body: "test" }}
        assert_redirected_to(forum_topic_path(@forum_topic, anchor: "forum_post_#{@forum_post.id}"))
      end

      should "not allow users to update their own posts in locked topics" do
        as(@user) { @forum_post.topic.update!(is_locked: true) }

        put_auth forum_post_path(@forum_post), @user, params: { forum_post: { body: "test" }}
        assert_response 403
      end

      should "not allow users to update other people's posts" do
        put_auth forum_post_path(@forum_post), @other_user, params: { forum_post: { body: "test" }}
        assert_response 403
      end

      should "allow moderators to update other people's posts" do
        put_auth forum_post_path(@forum_post), @mod, params: { forum_post: { body: "test" }}
        assert_redirected_to(forum_topic_path(@forum_topic, anchor: "forum_post_#{@forum_post.id}"))
      end
    end

    context "destroy action" do
      should "allow mods to delete posts" do
        delete_auth forum_post_path(@forum_post), @mod
        assert_redirected_to(forum_post_path(@forum_post))
        assert_equal(true, @forum_post.reload.is_deleted?)
      end

      should "not allow users to delete their own posts" do
        delete_auth forum_post_path(@forum_post), @user
        assert_response 403
        assert_equal(false, @forum_post.reload.is_deleted?)
      end
    end

    context "undelete action" do
      should "allow mods to undelete posts" do
        as(@mod) { @forum_post.update!(is_deleted: true) }
        post_auth undelete_forum_post_path(@forum_post), @mod
        assert_redirected_to(forum_post_path(@forum_post))
        assert_equal(false, @forum_post.reload.is_deleted?)
      end

      should "not allow users to undelete their own posts" do
        as(@mod) { @forum_post.update!(is_deleted: true) }
        post_auth undelete_forum_post_path(@forum_post), @user
        assert_response 403
        assert_equal(true, @forum_post.reload.is_deleted?)
      end
    end
  end
end
