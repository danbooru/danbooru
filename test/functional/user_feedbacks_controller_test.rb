require 'test_helper'

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  context "The user feedbacks controller" do
    setup do
      @user = create(:user, name: "cirno")
      @critic = create(:gold_user, name: "eiki")
      @mod = create(:moderator_user, id: 1000)
      @user_feedback = create(:user_feedback, user: @user, creator: @critic)
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

    context "show action" do
      should "allow all users to see undeleted feedbacks" do
        get user_feedback_path(@user_feedback)
        assert_response :success
      end

      should "allow moderators to see deleted feedbacks" do
        as(@user) { @user_feedback.update!(is_deleted: true) }
        get_auth user_feedback_path(@user_feedback), @mod
        assert_response :success
      end
    end

    context "index action" do
      setup do
        @other_feedback = create(:user_feedback, user: @user, creator: @mod, body: "blah", category: "neutral")
        @unrelated_feedback = create(:user_feedback, is_deleted: true)
      end

      should "render" do
        get_auth user_feedbacks_path, @user
        assert_response :success
      end

      context "as a user" do
        setup do
          CurrentUser.user = @user
        end

        should respond_to_search({}).with { [@other_feedback, @user_feedback] }
        should respond_to_search(body_matches: "blah").with { @other_feedback }
        should respond_to_search(category: "positive").with { @user_feedback }
        should respond_to_search(is_deleted: "true").with { [] }

        context "using includes" do
          should respond_to_search(creator_name: "eiki").with { @user_feedback }
          should respond_to_search(creator_id: 1000).with { @other_feedback }
          should respond_to_search(creator: {level: User::Levels::GOLD}).with { @user_feedback }
        end
      end

      context "as a moderator" do
        setup do
          CurrentUser.user = @mod
        end

        should respond_to_search({}).with { [@unrelated_feedback, @other_feedback, @user_feedback] }
        should respond_to_search(is_deleted: "true").with { @unrelated_feedback }

        context "using includes" do
          should respond_to_search(user_name: "cirno").with { [@other_feedback, @user_feedback] }
        end
      end
    end

    context "create action" do
      should "allow gold users to create new feedbacks" do
        assert_difference("UserFeedback.count", 1) do
          post_auth user_feedbacks_path, @critic, params: {:user_feedback => {:category => "positive", :user_name => @user.name, :body => "xxx"}}
          assert_response :redirect
        end
      end

      should "not allow users to create feedbacks for themselves" do
        assert_no_difference("UserFeedback.count") do
          post_auth user_feedbacks_path, @critic, params: { user_feedback: { user_id: @critic.id, category: "positive", body: "xxx" }}
          assert_response 403
        end
      end
    end

    context "update action" do
      should "allow updating undeleted feedbacks" do
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { category: "positive" }}

        assert_redirected_to(@user_feedback)
        assert_equal("positive", @user_feedback.reload.category)
      end

      should "not allow updating deleted feedbacks" do
        as(@user) { @user_feedback.update!(is_deleted: true) }
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { body: "test" }}

        assert_response 403
      end

      should "allow deleting feedbacks given to others" do
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { is_deleted: true }}

        assert_response :redirect
        assert_equal(true, @user_feedback.reload.is_deleted)
      end

      context "by a moderator" do
        should "allow updating feedbacks given to other users" do
          put_auth user_feedback_path(@user_feedback), @mod, params: { user_feedback: { is_deleted: "true" }}

          assert_redirected_to @user_feedback
          assert(@user_feedback.reload.is_deleted?)
        end

        should "not allow updating feedbacks given to themselves" do
          @user_feedback = create(:user_feedback, user: @mod, creator: @mod)
          put_auth user_feedback_path(@user_feedback), @mod, params: { id: @user_feedback.id, user_feedback: { is_deleted: "true" }}

          assert_response 403
          refute(@user_feedback.reload.is_deleted?)
        end
      end
    end
  end
end
