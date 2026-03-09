require "test_helper"

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  context "The user feedbacks controller" do
    setup do
      @user = create(:user)
      @critic = create(:gold_user)
      @mod = create(:moderator_user)
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
        @user_feedback = create(:user_feedback, is_deleted: true)
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
        user_feedbacks = respond_to_search.as_user { @user }

        should user_feedbacks.with { [@other_feedback, @user_feedback] }
        should user_feedbacks.search_params(body_matches: "blah").with { @other_feedback }
        should user_feedbacks.search_params(category: "positive").with { @user_feedback }
        should user_feedbacks.search_params(is_deleted: "true").with { [] }

        should user_feedbacks.search_params(creator_name: -> { @critic.name }).with { @user_feedback }
        should user_feedbacks.search_params(creator_id: -> { @mod.id }).with { @other_feedback }
        should user_feedbacks.search_params(creator: { level: User::Levels::GOLD }).with { @user_feedback }
      end

      context "as a moderator" do
        user_feedbacks = respond_to_search.as_user { @mod }

        should user_feedbacks.with { [@unrelated_feedback, @other_feedback, @user_feedback] }
        should user_feedbacks.search_params(is_deleted: "true").with { @unrelated_feedback }
        should user_feedbacks.search_params(user_name: -> { @user.name }).with { [@other_feedback, @user_feedback] }
      end
    end

    context "create action" do
      should "allow gold users to create positive feedbacks" do
        assert_difference("UserFeedback.count", 1) do
          post_auth user_feedbacks_path, @critic, params: { user_feedback: { category: "positive", user_name: @user.name, body: "xxx" }}
          assert_response :redirect
        end
      end

      should "allow gold users to create neutral feedbacks" do
        assert_difference("UserFeedback.count", 1) do
          post_auth user_feedbacks_path, @critic, params: { user_feedback: { category: "positive", user_name: @user.name, body: "xxx" }}
          assert_response :redirect
        end
      end

      should "allow gold users to create negative feedbacks" do
        assert_difference("UserFeedback.count", 1) do
          post_auth user_feedbacks_path, @critic, params: { user_feedback: { category: "negative", user_name: @user.name, body: "xxx" }}
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
        assert_equal(0, ModAction.count)
      end

      should "not allow updating deleted feedbacks" do
        @user_feedback = create(:user_feedback, user: @user, creator: @critic, is_deleted: true)
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { body: "test" }}

        assert_response 403
      end

      should "allow deleting feedbacks given to others" do
        put_auth user_feedback_path(@user_feedback), @critic, params: { user_feedback: { is_deleted: true }}

        assert_response :redirect
        assert_equal(true, @user_feedback.reload.is_deleted)
        assert_equal(0, ModAction.count)
      end

      context "by a moderator" do
        should "allow updating feedbacks given to other users" do
          put_auth user_feedback_path(@user_feedback), @mod, params: { user_feedback: { body: "blah" }}

          assert_redirected_to @user_feedback
          assert_equal("blah", @user_feedback.reload.body)
          assert_match(%r{updated user feedback for "#{@user.name}":/users/#{@user.id}}, ModAction.last.description)
          assert_equal("user_feedback_update", ModAction.last.category)
          assert_equal(@user, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end

        should "allow deleting feedbacks given to other users" do
          put_auth user_feedback_path(@user_feedback), @mod, params: { user_feedback: { is_deleted: "true" }}

          assert_redirected_to @user_feedback
          assert(@user_feedback.reload.is_deleted?)
          assert_match(%r{deleted user feedback for "#{@user.name}":/users/#{@user.id}}, ModAction.last.description)
          assert_equal("user_feedback_delete", ModAction.last.category)
          assert_equal(@user, ModAction.last.subject)
          assert_equal(@mod, ModAction.last.creator)
        end

        should "not allow updating feedbacks given to themselves" do
          @user_feedback = create(:user_feedback, user: @mod, creator: @mod)
          put_auth user_feedback_path(@user_feedback), @mod, params: { id: @user_feedback.id, user_feedback: { is_deleted: "true" }}

          assert_response 403
          assert_equal(false, @user_feedback.reload.is_deleted?)
        end
      end
    end
  end
end
