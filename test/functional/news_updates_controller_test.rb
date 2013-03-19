require 'test_helper'

class NewsUpdatesControllerTest < ActionController::TestCase
  context "the news updates controller" do
    setup do
      @admin = FactoryGirl.create(:admin_user)
      CurrentUser.user = @admin
      CurrentUser.ip_addr = "127.0.0.1"
      @news_update = FactoryGirl.create(:news_update)
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      should "render" do
        get :index, {}, :user_id => @admin.id
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, :user_id => @admin.id
        assert_response :success
      end
    end

    context "edit action" do
      should "render" do
        get :edit, {:id => @news_update.id}, {:user_id => @admin.id}
        assert_response :success
      end
    end

    context "update action" do
      should "work" do
        post :update, {:id => @news_update.id, :news_update => {:message => "zzz"}}, {:user_id => @admin.id}
        assert_redirected_to(news_updates_path)
      end
    end

    context "create action" do
      should "work" do
        post :create,  {:news_update => {:message => "zzz"}}, {:user_id => @admin.id}
        assert_redirected_to(news_updates_path)
      end
    end

    context "destroy action" do
      should "work" do
        post :destroy, {:id => @news_update.id, :format => "js"}, {:user_id => @admin.id}
        assert_response :success
      end
    end
  end
end
