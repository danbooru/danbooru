require 'test_helper'

class PostAppealsControllerTest < ActionDispatch::IntegrationTest
  context "The post appeals controller" do
    setup do
      @user = create(:user, name: "orin")
      @post = create(:post, id: 101, is_deleted: true)
    end

    context "new action" do
      should "render" do
        get_auth new_post_appeal_path, @user
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        @appeal = create(:post_appeal)
        get post_appeal_path(@appeal)
        assert_redirected_to post_appeals_path(search: { id: @appeal.id })
      end
    end

    context "index action" do
      setup do
        as(@user) do
          @post_appeal = create(:post_appeal, post: @post, creator: @user)
          @unrelated_appeal = create(:post_appeal, reason: "Good.")
          @resolved_appeal = create(:post_appeal)
          @resolved_appeal.post.update(is_deleted: false)
        end
      end

      should "render" do
        get_auth post_appeals_path, @user
        assert_response :success
      end

      should respond_to_search({}).with { [@resolved_appeal, @unrelated_appeal, @post_appeal] }
      should respond_to_search(reason_matches: "Good.").with { @unrelated_appeal }
      should respond_to_search(is_resolved: "true").with { @resolved_appeal }

      context "using includes" do
        should respond_to_search(post_id: 101).with { @post_appeal }
        should respond_to_search(post: {is_deleted: "true"}).with { [@unrelated_appeal, @post_appeal] }
        should respond_to_search(creator_name: "orin").with { @post_appeal }
      end
    end

    context "create action" do
      should "create a new appeal" do
        assert_difference("PostAppeal.count", 1) do
          post_auth post_appeals_path, @user, params: {:format => "js", :post_appeal => {:post_id => @post.id, :reason => "xxx"}}
          assert_response :success
        end
      end
    end
  end
end
