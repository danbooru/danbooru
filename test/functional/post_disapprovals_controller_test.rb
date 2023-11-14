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
        should respond_to_search(user_name: "eiki").with { [] }
      end

      should "allow mods to see disapprover names" do
        get_auth post_disapprovals_path, create(:mod_user)
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-approver", true
      end

      should "not allow non-mods to see disapprover names" do
        get post_disapprovals_path
        assert_response :success
        assert_select "tr#post-disapproval-#{@post_disapproval.id} .created-column a.user-approver", false
      end

      context "when a non-mod searches by disapprover name" do
        should respond_to_search(user_name: "eiki").with { [] }
      end

      context "when a mod searches by disapprover name" do
        setup { CurrentUser.user = create(:mod_user) }
        should respond_to_search(user_name: "eiki").with { @user_disapproval }
      end

      context "when a disapprover searches by their own name" do
        setup { CurrentUser.user = @approver }
        should respond_to_search(user_name: "eiki").with { @user_disapproval }
      end
    end

    context "show action" do
      setup do
        @disapproval = create(:post_disapproval)
      end

      should "render for html" do
        get post_disapproval_path(@disapproval)

        assert_redirected_to post_disapprovals_path(search: { id: @disapproval.id })
      end

      should "render for json" do
        get post_disapproval_path(@disapproval), as: :json

        assert_response :success
      end
    end

    context "update action" do
      setup do
        @post = create(:post, is_pending: true)
        @approver = create(:approver, name: "alice-san")
        @another_approver = create(:approver, name: "bob-kun")
        @post_disapproval = create(:post_disapproval, post: @post, user: @approver, reason: "poor_quality")
      end

      should "allow editing of disapprovals" do
        put_auth post_disapproval_path(@post_disapproval), @approver, params: {post_disapproval: {reason: "breaks_rules"}}

        assert_redirected_to(@post)
        assert_equal("breaks_rules", @post_disapproval.reload.reason)
      end

      should "not allow editing by another user" do
        put_auth post_disapproval_path(@post_disapproval), @another_approver, params: {post_disapproval: {reason: "disinterest"}}

        assert_response 403
        assert_equal("poor_quality", @post_disapproval.reload.reason)
      end
    end
  end
end
