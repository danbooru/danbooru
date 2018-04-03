require 'test_helper'

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  context "The user feedbacks controller" do
    setup do
      @user = create(:user)
      @critic = create(:gold_user)
      @mod = create(:moderator_user)
    end

    context "new action" do
      should "render" do
        get_auth new_user_feedback_path, @critic, params: { user_feedback: { user_id: @user.id } }
        assert_response :success
      end
    end

    context "edit action" do
      setup do
        as(@critic) do
          @user_feedback = create(:user_feedback, user: @user)
        end
      end

      should "render" do
        get_auth edit_user_feedback_path(@user_feedback), @critic
        assert_response :success
      end
    end

    context "index action" do
      setup do
        as(@critic) do
          @user_feedback = create(:user_feedback, user: @user)
        end
      end

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
        as(@critic) do
          @feedback = create(:user_feedback, user: @user, category: "negative")
        end
        put_auth user_feedback_path(@feedback), @critic, params: { id: @feedback.id, user_feedback: { category: "positive" }}

        assert_redirected_to(@feedback)
        assert("positive", @feedback.reload.category)
      end
    end

    context "destroy action" do
      setup do
        as(@critic) do
          @user_feedback = create(:user_feedback, user: @user)
        end
      end

      should "delete a feedback" do
        assert_difference "UserFeedback.count", -1 do
          delete_auth user_feedback_path(@user_feedback), @critic
        end
      end

      context "by a moderator" do
        should "allow deleting feedbacks given to other users" do
          assert_difference "UserFeedback.count", -1 do
            delete_auth user_feedback_path(@user_feedback), @mod
          end
        end

        should "not allow deleting feedbacks given to themselves" do
          as(@critic) do
            @user_feedback = create(:user_feedback, user: @mod)
          end

          assert_difference "UserFeedback.count", 0 do
            delete_auth user_feedback_path(@user_feedback), @mod
          end
        end
      end
    end
  end
end
