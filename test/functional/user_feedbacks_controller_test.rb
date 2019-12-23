require 'test_helper'

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  context "The user feedbacks controller" do
    setup do
      @user = create(:user)
      @critic = create(:gold_user)
      @mod = create(:moderator_user)
      @user_feedback = as(@critic) { create(:user_feedback, user: @user) }
    end

    context "new action" do
      should "render" do
        get_auth new_user_feedback_path, @critic, params: { user_feedback: { user_id: @user.id } }
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get_auth edit_user_feedback_path(@user_feedback), @critic
        assert_response :success
      end
    end

    context "index action" do
      should "render" do
        get_auth user_feedbacks_path, @user
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth user_feedbacks_path, @critic, params: {:search => {:user_id => @user.id}}
          assert_response :success
        end
      end
    end

    context "create action" do
      should "create a new feedback" do
        assert_difference("UserFeedback.count", 1) do
          post_auth user_feedbacks_path, @critic, params: {:user_feedback => {:category => "positive", :user_name => @user.name, :body => "xxx"}}
        end
      end
    end

    context "update action" do
      should "update the feedback" do
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { category: "positive" }}

        assert_redirected_to(@user_feedback)
        assert("positive", @user_feedback.reload.category)
      end

      context "by a moderator" do
        should "allow deleting feedbacks given to other users" do
          put_auth user_feedback_path(@user_feedback), @mod, params: { user_feedback: { is_deleted: "true" }}

          assert_redirected_to @user_feedback
          assert(@user_feedback.reload.is_deleted?)
        end

        should "not allow deleting feedbacks given to themselves" do
          @user_feedback = as(@critic) { create(:user_feedback, user: @mod) }
          put_auth user_feedback_path(@user_feedback), @mod, params: { id: @user_feedback.id, user_feedback: { is_deleted: "true" }}

          assert_response 403
          refute(@user_feedback.reload.is_deleted?)
        end
      end
    end
  end
end
