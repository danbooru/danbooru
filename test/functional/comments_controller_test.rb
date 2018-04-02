require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  context "A comments controller" do
    setup do
      @mod = FactoryBot.create(:moderator_user)
      @user = FactoryBot.create(:member_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)

      @post = FactoryBot.create(:post)
      @comment = FactoryBot.create(:comment, :post => @post)
      CurrentUser.scoped(@mod) do
        @mod_comment = FactoryBot.create(:comment, :post => @post)
      end
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "render for post" do
        get comments_path(post_id: @post.id, group_by: "post", format: "js")
        assert_response :success
      end

      should "render by post" do
        get comments_path(group_by: "post")
        assert_response :success
      end

      should "render by comment" do
        get comments_path(group_by: "comment")
        assert_response :success
      end

      should "render for atom feeds" do
        get comments_path(format: "atom")
        assert_response :success
      end
    end

    context "search action" do
      should "render" do
        get search_comments_path
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get comment_path(@comment.id)
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_comment_path(@comment.id), @user
        assert_response :success
      end
    end

    context "update action" do
      context "when updating another user's comment" do
        should "succeed if updater is a moderator" do
          put_auth comment_path(@comment.id), @user, params: {comment: {body: "abc"}}
          assert_equal("abc", @comment.reload.body)
          assert_redirected_to post_path(@comment.post)
        end

        should "fail if updater is not a moderator" do
          put_auth comment_path(@mod_comment.id), @user, params: {comment: {body: "abc"}}
          assert_not_equal("abc", @mod_comment.reload.body)
          assert_response 403
        end
      end

      context "when stickying a comment" do
        should "succeed if updater is a moderator" do
          put_auth comment_path(@comment.id), @mod, params: {comment: {is_sticky: true}}
          assert_equal(true, @comment.reload.is_sticky)
          assert_redirected_to @comment.post
        end

        should "fail if updater is not a moderator" do
          put_auth comment_path(@comment.id), @user, params: {comment: {is_sticky: true}}
          assert_equal(false, @comment.reload.is_sticky)
        end
      end

      should "update the body" do
        put_auth comment_path(@comment.id), @comment.creator, params: {comment: {body: "abc"}}
        assert_equal("abc", @comment.reload.body)
        assert_redirected_to post_path(@comment.post)
      end

      should "allow changing the body and is_deleted" do
        put_auth comment_path(@comment.id), @comment.creator, params: {comment: {body: "herp derp", is_deleted: true}}
        assert_equal("herp derp", @comment.reload.body)
        assert_equal(true, @comment.is_deleted)
        assert_redirected_to post_path(@post)
      end

      should "not allow changing do_not_bump_post or post_id" do
        as_user do
          @another_post = create(:post)
        end
        put_auth comment_path(@comment.id), @comment.creator, params: {do_not_bump_post: true, post_id: @another_post.id}
        assert_equal(false, @comment.reload.do_not_bump_post)
        assert_equal(@post.id, @comment.post_id)
      end
    end

    context "new action" do
      should "redirect" do
        get_auth new_comment_path, @user
        assert_redirected_to comments_path
      end
    end

    context "create action"do
      should "create a comment" do
        assert_difference("Comment.count", 1) do
          post_auth comments_path, @user, params: {comment: FactoryBot.attributes_for(:comment, post_id: @post.id)}
        end
        comment = Comment.last
        assert_redirected_to post_path(comment.post)
      end

      should "not allow commenting on nonexistent posts" do
        assert_difference("Comment.count", 0) do
          post_auth comments_path, @user, params: {comment: FactoryBot.attributes_for(:comment, post_id: -1)}
        end
        assert_redirected_to comments_path
      end
    end

    context "destroy action" do
      should "mark comment as deleted" do
        delete_auth comment_path(@comment.id), @user
        assert_equal(true, @comment.reload.is_deleted)
        assert_redirected_to @comment
      end
    end

    context "undelete action" do
      setup do
        @comment.delete!        
      end
      
      should "mark comment as undeleted" do
        post_auth undelete_comment_path(@comment.id), @user
        assert_equal(false, @comment.reload.is_deleted)
        assert_redirected_to(@comment)
      end
    end
  end
end
