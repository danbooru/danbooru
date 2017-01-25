require 'test_helper'

class CommentVotesControllerTest < ActionController::TestCase
  context "A comment votes controller" do
    setup do
      CurrentUser.user = @user = FactoryGirl.create(:user)
      CurrentUser.ip_addr = "127.0.0.1"
      Danbooru.config.stubs(:member_comment_time_threshold).returns(1.week.from_now)
      @comment = FactoryGirl.create(:comment)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "#create.json" do
      should "create a vote" do
        assert_difference("CommentVote.count", 1) do
          post :create, {:format => "json", :comment_id => @comment.id, :score => 1}, {:user_id => @user.id}
          assert_response :success
          assert_equal("{\"success\": true}", @response.body.strip)
        end
      end

      should "fail silently on errors" do
        FactoryGirl.create(:comment_vote, :comment => @comment, :score => -1)
        assert_difference("CommentVote.count", 0) do
          post :create, {:format => "json", :comment_id => @comment.id, :score => -1}, {:user_id => @user.id}
          assert_response 422
          assert_equal("{\"success\": false, \"errors\": \"Validation failed: You have already voted for this comment\"}", @response.body.strip)
        end
      end
    end

    context "#create.js" do
      should "create a vote" do
        assert_difference("CommentVote.count", 1) do
          post :create, {:format => "js", :comment_id => @comment.id, :score => 1}, {:user_id => @user.id}
          assert_response :success
        end
      end

      should "fail on errors" do
        FactoryGirl.create(:comment_vote, :comment => @comment, :score => -1)
        assert_difference("CommentVote.count", 0) do
          post :create, {:format => "js", :comment_id => @comment.id, :score => -1}, {:user_id => @user.id}
          assert_response 422
        end
      end
    end
  end
end
