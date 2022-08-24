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

      context "using includes" do
        should respond_to_search(post_id: 101).with { @post_appeal }
        should respond_to_search(post: {is_deleted: "true"}).with { [@unrelated_appeal, @post_appeal] }
        should respond_to_search(creator_name: "orin").with { @post_appeal }
      end
    end

    context "create action" do
      context "appealing a deleted post" do
        should "create a new appeal" do
          @post = create(:post, is_deleted: true)

          assert_difference("PostAppeal.count", 1) do
            post_auth post_appeals_path, @user, params: { post_appeal: { post_id: @post.id, reason: "xxx" }}, as: :json
          end

          assert_response :success
        end
      end

      context "appealing a flagged post" do
        should "fail" do
          @flag = create(:post_flag)

          assert_no_difference("PostAppeal.count") do
            post_auth post_appeals_path, @user, params: { post_appeal: { post_id: @flag.post.id, reason: "xxx" }}, as: :json
          end

          assert_response 422
          assert_equal(["cannot be appealed"], response.parsed_body.dig("errors", "post"))
        end
      end

      context "appealing a pending post" do
        should "fail" do
          @post = create(:post, is_pending: true)

          assert_no_difference("PostAppeal.count") do
            post_auth post_appeals_path, @user, params: { post_appeal: { post_id: @post.id, reason: "xxx" }}, as: :json
          end

          assert_response 422
          assert_equal(["cannot be appealed"], response.parsed_body.dig("errors", "post"))
        end
      end

      context "appealing an already appealed post" do
        should "fail" do
          @appeal = create(:post_appeal)

          assert_no_difference("PostAppeal.count") do
            post_auth post_appeals_path, @user, params: { post_appeal: { post_id: @appeal.post.id, reason: "xxx" }}, as: :json
          end

          assert_response 422
          assert_equal(["cannot be appealed"], response.parsed_body.dig("errors", "post"))
        end
      end
    end

    context "update action" do
      should "allow the appealer to update the appeal" do
        @appealer = create(:user)
        @post_appeal = create(:post_appeal, creator: @appealer, reason: "xxx")
        put_auth post_appeal_path(@post_appeal), @appealer, params: { post_appeal: { reason: "yes" }}

        assert_redirected_to @post_appeal.post
        assert_equal("yes", @post_appeal.reload.reason)
      end

      should "return an error if the appeal is too long" do
        @appealer = create(:user)
        @post_appeal = create(:post_appeal, creator: @appealer, reason: "xxx")
        put_auth post_appeal_path(@post_appeal), @appealer, params: { post_appeal: { reason: "x"*1000 }}

        assert_response :success
        assert_equal("xxx", @post_appeal.reload.reason)
      end

      should "not allow the appealer to update a rejected appeal" do
        @appealer = create(:user)
        @post_appeal = create(:post_appeal, creator: @appealer, reason: "xxx", status: "rejected")
        put_auth post_appeal_path(@post_appeal), @appealer, params: { post_appeal: { reason: "no" }}

        assert_response 403
        assert_equal("xxx", @post_appeal.reload.reason)
      end

      should "not allow other users to update the appeal" do
        @post_appeal = create(:post_appeal, reason: "xxx")
        put_auth post_appeal_path(@post_appeal), create(:mod_user), params: { post_appeal: { reason: "no" }}

        assert_response 403
        assert_equal("xxx", @post_appeal.reload.reason)
      end
    end
  end
end
