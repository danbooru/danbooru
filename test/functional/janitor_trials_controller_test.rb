require 'test_helper'

class JanitorTrialsControllerTest < ActionController::TestCase
  context "The janitor trials controller" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @admin.id}
        assert_response :success
      end
    end

    context "create action" do
      should "create a new janitor trial" do
        assert_difference("JanitorTrial.count", 1) do
          post :create, {:janitor_trial => {:user_id => @user.id}}, {:user_id => @admin.id}
        end
      end
    end

    context "promote action" do
      setup do
        @janitor_trial = FactoryGirl.create(:janitor_trial, :user_id => @user.id)
      end

      should "promote the janitor trial" do
        post :promote, {:id => @janitor_trial.id}, {:user_id => @admin.id}
        @user.reload
        assert(@user.is_janitor?)
        @janitor_trial.reload
        assert_equal(false, @janitor_trial.active?)
      end
    end

    context "demote action" do
      setup do
        @janitor_trial = FactoryGirl.create(:janitor_trial, :user_id => @user.id)
      end

      should "demote the janitor trial" do
        post :demote, {:id => @janitor_trial.id}, {:user_id => @admin.id}
        @user.reload
        assert(!@user.is_janitor?)
        @janitor_trial.reload
        assert_equal(false, @janitor_trial.active?)
      end
    end

    context "index action" do
      setup do
        FactoryGirl.create(:janitor_trial)
      end

      should "render" do
        get :index, {}, {:user_id => @admin.id}
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get :index, {:search => {:user_name => @user.name}}, {:user_id => @admin.id}
          assert_response :success
        end
      end
    end
  end
end
