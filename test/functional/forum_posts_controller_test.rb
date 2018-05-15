require 'test_helper'

class ForumPostsControllerTest < ActionDispatch::IntegrationTest
  context "The forum posts controller" do
    setup do
      @user = create(:user)
      @other_user = create(:user)
      @mod = create(:moderator_user)
      as_user do
        @forum_topic = create(:forum_topic, :title => "my forum topic")
        @forum_post = create(:forum_post, :topic_id => @forum_topic.id, :body => "alias xxx -> yyy")
      end
    end

    context "with votes" do
      setup do
        as_user do
          @tag_alias = create(:tag_alias, forum_post: @forum_post, status: "pending")
          @vote = create(:forum_post_vote, forum_post: @forum_post, score: 1)
          @forum_post.reload
        end
      end

      should "render the vote links" do
        get_auth forum_topic_path(@forum_topic), @mod
        assert_select "a[title='Vote up']"
      end

      should "render existing votes" do
        get_auth forum_topic_path(@forum_topic), @mod
        assert_select "li.vote-score-up"
      end

      context "after the alias is rejected" do
        setup do
          as(@mod) do
            @tag_alias.reject!
          end
          get_auth forum_topic_path(@forum_topic), @mod
        end

        should "hide the vote links" do
          assert_select "a[title='Vote up']", false
        end

        should "still render existing votes" do
          assert_select "li.vote-score-up"
        end
      end
    end

    context "index action" do
      should "list all forum posts" do
        get forum_posts_path
        assert_response :success
      end

      context "with search conditions" do
        should "list all matching forum posts" do
          get forum_posts_path, params: {:search => {:body_matches => "xxx"}}
          assert_response :success
          assert_select "#forum-post-#{@forum_post.id}"
        end

        should "list nothing for when the search matches nothing" do
          get forum_posts_path, params: {:search => {:body_matches => "bababa"}}
          assert_response :success
          assert_select "#forum-post-#{@forum_post.id}", false
        end

        should "list by creator id" do
          get forum_posts_path, params: {:search => {:creator_id => @user.id}}
          assert_response :success
          assert_select "#forum-post-#{@forum_post.id}"
        end
      end

      context "with private topics" do
        setup do
          as(@mod) do
            @mod_topic = create(:mod_up_forum_topic)
            @mod_posts = 2.times.map do
              create(:forum_post, :topic_id => @mod_topic.id)
            end
          end
          @mod_post_ids = ([@forum_post] + @mod_posts).map(&:id).reverse
        end

        should "list only permitted posts for members" do
          get forum_posts_path

          assert_response :success
          assert_select "#forum-post-#{@forum_post.id}"
          assert_select "#forum-post-#{@mod_posts[0].id}", false
        end

        should "list only permitted posts for mods" do
          get_auth forum_posts_path, @mod

          assert_response :success
          assert_select "#forum-post-#{@mod_posts[0].id}"
        end
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
    end

    context "new action" do
      should "render" do
        get_auth new_forum_post_path, @user, params: {:topic_id => @forum_topic.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new forum post" do
        assert_difference("ForumPost.count", 1) do
          post_auth forum_posts_path, @user, params: {:forum_post => {:body => "xaxaxa", :topic_id => @forum_topic.id}}
        end

        forum_post = ForumPost.last
        assert_redirected_to(forum_topic_path(@forum_topic))
      end
    end

    context "destroy action" do
      should "destroy the posts" do
        delete_auth forum_post_path(@forum_post), @mod
        assert_redirected_to(forum_post_path(@forum_post))
        @forum_post.reload
        assert_equal(true, @forum_post.is_deleted?)
      end
    end

    context "undelete action" do
      setup do
        as(@mod) do
          @forum_post.update(is_deleted: true)
        end
      end

      should "restore the post" do
        post_auth undelete_forum_post_path(@forum_post), @mod
        assert_redirected_to(forum_post_path(@forum_post))
        @forum_post.reload
        assert_equal(false, @forum_post.is_deleted?)
      end
    end
  end
end
