require 'test_helper'

class PostAppealsControllerTest < ActionDispatch::IntegrationTest
  context "The post appeals controller" do
    setup do
      @user = create(:user)
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
          @post = create(:post, :is_deleted => true)
          @post_appeal = create(:post_appeal, :post => @post)
        end
      end

      should "render" do
        get_auth post_appeals_path, @user
        assert_response :success
      end

      should "render for json" do
        get post_appeals_path, as: :json
        assert_response :success
      end

      context "with search parameters" do
        should "render" do
          get_auth post_appeals_path, @user, params: {:search => {:post_id => @post_appeal.post_id}}
          assert_response :success
        end
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
  end
end
