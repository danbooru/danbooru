require 'test_helper'

class PostApprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    setup do
      @approver = create(:approver)
    end

    context "create action" do
      context "for a pending post" do
        should "approve the post" do
          @post = create(:post, is_pending: true)
          post_auth post_approvals_path(post_id: @post.id, format: :js), @approver

          assert_response :success
          assert(!@post.reload.is_pending?)
        end
      end

      context "for a deleted post" do
        should "undelete the post" do
          @post = create(:post, is_deleted: true)
          post_auth post_approvals_path(post_id: @post.id, format: :js), @approver

          assert_response :success
          assert(!@post.reload.is_deleted?)
        end
      end

      should "not allow non-approvers to approve posts" do
        @post = create(:post, is_pending: true)
        post_auth post_approvals_path(post_id: @post.id, format: :js), create(:user)

        assert_response 403
        assert_equal(true, @post.reload.is_pending?)
      end
    end

    context "index action" do
      should "render" do
        @approval = create(:post_approval)
        get post_approvals_path
        assert_response :success
      end
    end
  end
end
