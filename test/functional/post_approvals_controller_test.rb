require 'test_helper'

class PostApprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    setup do
      @approver = create(:approver)
    end

    context "create action" do
      should "render" do
        @post = create(:post, is_pending: true)
        post_auth post_approvals_path(post_id: @post.id, format: :js), @approver

        assert_response :success
        assert(!@post.reload.is_pending?)
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
