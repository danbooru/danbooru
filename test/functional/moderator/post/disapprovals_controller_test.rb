require 'test_helper'

module Moderator
  module Post
    class DisapprovalsControllerTest < ActionDispatch::IntegrationTest
      context "The moderator post disapprovals controller" do
        setup do
          @admin = create(:admin_user)
          as_user do
            @post = create(:post, :is_pending => true)
          end
        end

        context "create action" do
          should "render" do
            assert_difference("PostDisapproval.count", 1) do
              post_auth moderator_post_disapprovals_path, @admin, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }
            end
            assert_response :success
          end

          context "for json" do
            should "render" do
              assert_difference("PostDisapproval.count", 1) do
                post_auth moderator_post_disapprovals_path, @admin, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
              end
              assert_response :success 
            end
          end
        end
      end
    end
  end
end
