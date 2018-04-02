require 'test_helper'

module Moderator
  module Post
    class ApprovalsControllerTest < ActionDispatch::IntegrationTest
      context "The moderator post approvals controller" do
        setup do
          @admin = create(:admin_user)
          as_admin do
            @post = create(:post, :is_pending => true)
          end
        end

        context "create action" do
          should "render" do
            post_auth moderator_post_approval_path, @admin, params: {:post_id => @post.id, :format => "js"}
            assert_response :success
            @post.reload
            assert(!@post.is_pending?)
          end
        end
      end
    end
  end
end
