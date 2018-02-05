require 'test_helper'

class UserFeedbacksControllerTest < ActionController::TestCase
  context "The user feedbacks controller" do
    setup do
      @user = FactoryGirl.create(:user)
      @critic = FactoryGirl.create(:gold_user)
      @mod = FactoryGirl.create(:moderator_user)
      CurrentUser.user = @critic
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "new action" do
      should "render" do
        get :new, { user_feedback: { user_id: @user.id } }, { user_id: @critic.id }
        assert_response :success
      end
    end

    context "edit action" do
      setup do
        @user_feedback = FactoryGirl.create(:user_feedback)
      end

      should "render" do
        get :edit, {:id => @user_feedback.id}, {:user_id => @critic.id}
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @user_feedback = FactoryGirl.create(:user_feedback)
      end

      should "render" do
        get :index, {}, {:user_id => @user.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get :index, {:search => {:user_id => @user.id}}, {:user_id => @critic.id}
          assert_response :success
        end
      end
    end

    context "create action" do
      should "create a new feedback" do
        assert_difference("UserFeedback.count", 1) do
          post :create, {:user_feedback => {:category => "positive", :user_name => @user.name, :body => "xxx"}}, {:user_id => @critic.id}
          assert_not_nil(assigns(:user_feedback))
          assert_equal([], assigns(:user_feedback).errors.full_messages)
        end
      end
    end

    context "update action" do
      should "update the feedback" do
        @feedback = FactoryGirl.create(:user_feedback, user: @user, category: "negative")
        put :update, { id: @feedback.id, user_feedback: { category: "positive" }}, { user_id: @critic.id }

        assert_redirected_to(@feedback)
        assert("positive", @feedback.reload.category)
      end
    end

    context "destroy action" do
      setup do
        @user_feedback = FactoryGirl.create(:user_feedback, user: @user)
      end

      should "delete a feedback" do
        assert_difference "UserFeedback.count", -1 do
          post :destroy, {:id => @user_feedback.id}, {:user_id => @critic.id}
        end
      end

      context "by a moderator" do
        should "allow deleting feedbacks given to other users" do
          assert_difference "UserFeedback.count", -1 do
            post :destroy, {:id => @user_feedback.id}, {:user_id => @mod.id}
          end
        end

        should "not allow deleting feedbacks given to themselves" do
          @user_feedback = FactoryGirl.create(:user_feedback, user: @mod)
          assert_difference "UserFeedback.count", 0 do
            post :destroy, {:id => @user_feedback.id}, {:user_id => @mod.id}
          end
        end
      end
    end
  end
end
