require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "A comments controller" do
    setup do
      @mod = FactoryGirl.create(:moderator_user)
      @user = FactoryGirl.create(:member_user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)

      @post = FactoryGirl.create(:post)
      @comment = FactoryGirl.create(:comment, :post => @post)
      CurrentUser.scoped(@mod) do
        @mod_comment = FactoryGirl.create(:comment, :post => @post)
      end
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "render for post" do
        xhr :get, :index, { post_id: @post.id, group_by: "post", format: "js" }
        assert_response :success
      end

      should "render by post" do
        get :index, {:group_by => "post"}
        assert_response :success
      end

      should "render by comment" do
        get :index, {:group_by => "comment"}
        assert_response :success
      end

      should "render for atom feeds" do
        get :index, {:format => "atom"}
        assert_response :success
      end
    end

    context "search action" do
      should "render" do
        get :search
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get :show, {:id => @comment.id}
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get :edit, {:id => @comment.id}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "update action" do
      context "when updating another user's comment" do
        should "succeed if updater is a moderator" do
          post :update, {:id => @comment.id, :comment => {:body => "abc"}}, {:user_id => @mod.id}
          assert_equal("abc", @comment.reload.body)
          assert_redirected_to post_path(@comment.post)
        end

        should "fail if updater is not a moderator" do
          post :update, {:id => @mod_comment.id, :comment => {:body => "abc"}}, {:user_id => @user.id}
          assert_not_equal("abc", @mod_comment.reload.body)
          assert_response 403
        end
      end

      context "when stickying a comment" do
        should "succeed if updater is a moderator" do
          CurrentUser.user = @mod
          post :update, {:id => @comment.id, :comment => {:is_sticky => true}}, {:user_id => @mod.id}
          assert_equal(true, @comment.reload.is_sticky)
          assert_redirected_to @comment.post
        end

        should "fail if updater is not a moderator" do
          post :update, {:id => @comment.id, :comment => {:is_sticky => true}}, {:user_id => @user.id}
          assert_equal(false, @comment.reload.is_sticky)
        end
      end

      should "update the body" do
        post :update, {:id => @comment.id, :comment => {:body => "abc"}}, {:user_id => @comment.creator_id}
        assert_equal("abc", @comment.reload.body)
        assert_redirected_to post_path(@comment.post)
      end

      should "allow changing the body and is_deleted" do
        params = {
          id: @comment.id,
          comment: {
            body: "herp derp",
            is_deleted: true,
          }
        }

        post :update, params, { :user_id => @comment.creator_id }

        assert_equal("herp derp", @comment.reload.body)
        assert_equal(true, @comment.is_deleted)
        assert_redirected_to post_path(@post)
      end

      should "not allow changing do_not_bump_post or post_id" do
        params = {
          id: @comment.id,
          comment: {
            do_not_bump_post: true,
            post_id: FactoryGirl.create(:post).id,
          }
        }

        post :update, params, { :user_id => @comment.creator_id }

        assert_equal(false, @comment.reload.do_not_bump_post)
        assert_equal(@post.id, @comment.post_id)
      end
    end

    context "new action" do
      should "redirect" do
        get :new, {}, {:user_id => @user.id}
        assert_redirected_to comments_path
      end
    end

    context "create action"do
      should "create a comment" do
        assert_difference("Comment.count", 1) do
          post :create, {:comment => FactoryGirl.attributes_for(:comment, :post_id => @post.id)}, {:user_id => @user.id}
        end
        comment = Comment.last
        assert_redirected_to post_path(comment.post)
      end

      should "not allow commenting on nonexistent posts" do
        post :create, {:comment => FactoryGirl.attributes_for(:comment, :post_id => -1)}, {:user_id => @user.id}
        assert_response :error
      end
    end

    context "destroy action" do
      should "mark comment as deleted" do
        delete :destroy, {:id => @comment.id}, {:user_id => @user.id}
        assert_equal(true, @comment.reload.is_deleted)
        assert_redirected_to @comment
      end
    end

    context "undelete action" do
      should "mark comment as undeleted" do
        @comment.delete!
        put :undelete, { id: @comment.id }, { user_id: @user.id }

        assert_equal(false, @comment.reload.is_deleted)
        assert_redirected_to(@comment)
      end
    end
  end
end
