require 'test_helper'

class JanitorTrialsControllerTest < ActionDispatch::IntegrationTest
  context "The janitor trials controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
    end

    context "new action" do
      should "render" do
        get_auth new_janitor_trial_path, @admin
        assert_response :success
      end
    end

    context "create action" do
      should "create a new janitor trial" do
        assert_difference("JanitorTrial.count", 1) do
          post_auth janitor_trials_path, @admin, params: {:janitor_trial => {:user_id => @user.id}}
        end
      end
    end

    context "promote action" do
      setup do
        as(@admin) do
          @janitor_trial = create(:janitor_trial, :user_id => @user.id)
        end
      end

      should "promote the janitor trial" do
        put_auth promote_janitor_trial_path(@janitor_trial), @admin
        @user.reload
        assert(@user.can_approve_posts?)
        @janitor_trial.reload
        assert_equal(false, @janitor_trial.active?)
      end
    end

    context "demote action" do
      setup do
        as(@admin) do
          @janitor_trial = create(:janitor_trial, :user_id => @user.id)
        end
      end

      should "demote the janitor trial" do
        put_auth demote_janitor_trial_path(@janitor_trial), @admin
        @user.reload
        assert(!@user.can_approve_posts?)
        @janitor_trial.reload
        assert_equal(false, @janitor_trial.active?)
      end
    end

    context "index action" do
      setup do
        as(@admin) do
          create(:janitor_trial)
        end
      end

      should "render" do
        get_auth janitor_trials_path, @admin
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth janitor_trials_path, @admin, params: {:search => {:user_name => @user.name}}
          assert_response :success
        end
      end
    end
  end
end
