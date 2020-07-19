require 'test_helper'

class PostApprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post approvals controller" do
    setup do
      @approver = create(:approver, name: "eiki")
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
      setup do
        @post = create(:post, tag_string: "touhou", is_pending: true, uploader: build(:user, name: "komachi", created_at: 2.weeks.ago))
        @post_approval = create(:post_approval, post: @post)
        @user_approval = create(:post_approval, user: @approver)
        @unrelated_approval = create(:post_approval)
      end

      should "render" do
        get post_approvals_path
        assert_response :success
      end

      should respond_to_search({}).with { [@unrelated_approval, @user_approval, @post_approval] }

      context "using includes" do
        should respond_to_search(user_name: "eiki").with { @user_approval }
        should respond_to_search(post_tags_match: "touhou").with { @post_approval }
        should respond_to_search(post: {uploader_name: "komachi"}).with { @post_approval }
      end
    end
  end
end
