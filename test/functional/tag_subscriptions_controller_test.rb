require 'test_helper'

class TagSubscriptionsControllerTest < ActionController::TestCase
  context "The tag subscriptions controller" do
    setup do
      @user = FactoryGirl.create(:user)
      CurrentUser.user = @user
      CurrentUser.ip_addr = "127.0.0.1"
    end

    teardown do
      CurrentUser.user = nil
      CurrentUser.ip_addr = nil
    end

    context "index action" do
      setup do
        @tag_subscription = FactoryGirl.create(:tag_subscription, :name => "aaa")
      end

      should "list all visible tag subscriptions" do
        get :index
        assert_response :success
      end
    end

    context "posts action" do
      setup do
        @tag_subscription = FactoryGirl.create(:tag_subscription, :name => "aaa")
      end

      should "list all visible tag subscriptions" do
        get :posts, {:id => @tag_subscription.creator_id}
        assert_response :success
      end
    end

    context "edit action" do
      setup do
        @tag_subscription = FactoryGirl.create(:tag_subscription)
      end

      should "render" do
        get :edit, {:id => @tag_subscription.id}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "new action" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "create action" do
      should "not create a new tag subscription" do
        assert_no_difference("TagSubscription.count") do
          post :create, {:tag_subscription => {:name => "aaa", :tag_query => "bbb"}}, {:user_id => @user.id}
        end
      end
    end

    context "destroy action" do
      setup do
        @tag_subscription = FactoryGirl.create(:tag_subscription)
      end

      should "destroy the posts" do
        assert_difference("TagSubscription.count", -1) do
          post :destroy, {:id => @tag_subscription.id}, {:user_id => @user.id}
        end
      end
    end
  end
end
