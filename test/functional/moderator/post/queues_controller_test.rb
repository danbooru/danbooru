require 'test_helper'

module Moderator
  module Post
    class QueuesControllerTest < ActionController::TestCase
      context "The moderator post queues controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"

          @post = FactoryGirl.create(:post, :is_pending => true)
        end

        context "show action" do
          should "render" do
            get :show, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end

        context "random action" do
          should "render" do
            get :random, {}, {:user_id => @admin.id}
            assert_response :success
          end
        end
      end
    end
  end
end
