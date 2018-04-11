require 'test_helper'

module Moderator
  module Post
    class QueuesControllerTest < ActionDispatch::IntegrationTest
      context "The moderator post queues controller" do
        setup do
          @admin = create(:admin_user)
          @user = create(:user)
          as_user do
            @post = create(:post, :is_pending => true)
          end
        end

        context "show action" do
          should "render" do
            get_auth moderator_post_queue_path, @admin
            assert_response :success
          end
        end

        context "random action" do
          should "render" do
            get_auth moderator_post_queue_path, @admin
            assert_response :success
          end
        end
      end
    end
  end
end
