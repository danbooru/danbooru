require 'test_helper'

class ApiKeysControllerTest < ActionController::TestCase
  context "An api keys controller" do
    setup do
      @user = FactoryGirl.create(:gold_user)
    end

    context "#new" do
      should "render" do
        get :new, {}, {:user_id => @user.id}
        assert_response :success
      end
    end

    context "#create" do
      should "succeed" do
        assert_difference("ApiKey.count", 1) do
          post :create, {}, {:user_id => @user.id}
        end
      end

      context "when an api key already exists" do
        setup do
          ApiKey.generate!(@user)
        end

        should "not create another api key" do
          assert_difference("ApiKey.count", 0) do
            post :create, {}, {:user_id => @user.id}
          end
        end
      end
    end
  end
end