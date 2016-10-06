require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  context "A comments controller" do
    setup do
      CurrentUser.user = FactoryGirl.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      @post = FactoryGirl.create(:post)
      @comment = FactoryGirl.create(:comment, :post => @post)
      @user = FactoryGirl.create(:moderator_user)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "render by post" do
        get :index, {:group_by => "post"}
        assert_response :success
      end

      should "render by comment" do
        get :index, {:group_by => "comment"}
        assert_response :success
      end
    end

    context "update action" do
      should "update the comment" do
        post :update, {:id => @comment.id, :comment => {:body => "abc"}}, {:user_id => @comment.creator_id}
        assert_redirected_to post_path(@comment.post)
      end

      should "only allow changing the body" do
        params = {
          id: @comment.id,
          comment: {
            body: "herp derp",
            do_not_bump_post: true,
            is_deleted: true,
            post_id: FactoryGirl.create(:post).id,
          }
        }

        post :update, params, { :user_id => @comment.creator_id }
        @comment.reload

        assert_equal("herp derp", @comment.body)
        assert_equal(false, @comment.do_not_bump_post)
        assert_equal(false, @comment.is_deleted)
        assert_equal(@post.id, @comment.post_id)

        assert_redirected_to post_path(@post)
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
  end
end
