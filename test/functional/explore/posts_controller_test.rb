require "test_helper"

module Explore
  class PostsControllerTest < ActionController::TestCase
    context "in all cases" do
      setup do
        CurrentUser.user = FactoryGirl.create(:user)
        CurrentUser.ip_addr = "127.0.0.1"
        FactoryGirl.create(:post)
      end

      context "#popular" do
        should "render" do
          get :popular
          assert_response :success
        end
      end
    end
  end
end
