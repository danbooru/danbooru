require 'test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    CurrentUser.user = FactoryGirl.create(:mod_user)
    CurrentUser.ip_addr = "127.0.0.1"
    session[:user_id] = CurrentUser.user.id

    @users = FactoryGirl.create_list(:contributor_user, 2)
    @posts = @users.map { |u| FactoryGirl.create(:post, uploader: u) }
  end

  teardown do
    CurrentUser.user = nil
    CurrentUser.ip_addr = nil
    session[:user_id] = nil
  end

  context "The reports controller" do
    context "user_promotions action" do
      should "render" do
        get :user_promotions
        assert_response :success
      end
    end

    context "janitor_trials action" do
      should "render" do
        get :janitor_trials
        assert_response :success
      end
    end

    context "contributors action" do
      should "render" do
        get :contributors
        assert_response :success
      end
    end

    context "uploads action" do
      should "render" do
        get :uploads
        assert_response :success
      end
    end

    context "similar_users action" do
      should "render" do
        #get :similar_users
        #assert_response :success
      end
    end

    context "post_versions action" do
      should "render" do
        get :post_versions
        assert_response :success
      end
    end

    context "post_versions_create action" do
      should "render" do
        #post :post_versions_create, { tag: "touhou", type: "added" }
        #assert_response :success
      end
    end
  end
end
