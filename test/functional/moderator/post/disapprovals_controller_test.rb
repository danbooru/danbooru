require 'test_helper'

module Moderator
  module Post
    class DisapprovalsControllerTest < ActionController::TestCase
      context "The moderator post disapprovals controller" do
        setup do
          @admin = FactoryGirl.create(:admin_user)
          CurrentUser.user = @admin
          CurrentUser.ip_addr = "127.0.0.1"

          @post = FactoryGirl.create(:post, :is_pending => true)
        end

        context "create action" do
          should "render" do
            assert_difference("PostDisapproval.count", 1) do
              post :create, { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }, { user_id: @admin.id }
            end
            assert_response :success
          end
        end
      end
    end
  end
end
