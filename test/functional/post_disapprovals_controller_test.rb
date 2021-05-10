require 'test_helper'

class PostDisapprovalsControllerTest < ActionDispatch::IntegrationTest
  context "The post disapprovals controller" do
    setup do
      @approver = create(:approver, name: "eiki")
      @post = create(:post, tag_string: "touhou", is_pending: true, uploader: build(:user, name: "marisa", created_at: 2.weeks.ago))
    end

    context "create action" do
      should "render" do
        assert_difference("PostDisapproval.count", 1) do
          post_auth post_disapprovals_path, @approver, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }
          assert_response :success
        end
      end

      should "render for json" do
        assert_difference("PostDisapproval.count", 1) do
          post_auth post_disapprovals_path, @approver, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
          assert_response :success
        end
      end

      should "not allow non-approvers to create disapprovals" do
        assert_difference("PostDisapproval.count", 0) do
          post_auth post_disapprovals_path, create(:user), params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "json" }
          assert_response 403
        end
      end

      should "not allow disapproving active posts" do
        assert_difference("PostDisapproval.count", 0) do
          @post.update!(is_pending: false)
          post_auth post_disapprovals_path, @approver, params: { post_disapproval: { post_id: @post.id, reason: "breaks_rules" }, format: "js" }
          assert_response :success
        end
      end
    end

    context "index action" do
      setup do
        @post_disapproval = create(:post_disapproval, post: @post)
        @user_disapproval = create(:post_disapproval, user: @approver)
        @unrelated_disapproval = create(:post_disapproval, message: "bad")
      end

      should "render" do
        get post_disapprovals_path
        assert_response :success
      end

      should respond_to_search({}).with { [@unrelated_disapproval, @user_disapproval, @post_disapproval] }
      should respond_to_search(message: "bad").with { @unrelated_disapproval }

      context "using includes" do
        should respond_to_search(post_tags_match: "touhou").with { @post_disapproval }
        should respond_to_search(post: {uploader_name: "marisa"}).with { @post_disapproval }
        should respond_to_search(user_name: "eiki").with { @user_disapproval }
      end

      should "allow mods to see disapprover names" do
        get_auth post_disapprovals_path, create(:mod_user)
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-post-approver", true
      end

      should "not allow non-mods to see disapprover names" do
        get post_disapprovals_path
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-post-approver", false
      end
    end
  end
end
