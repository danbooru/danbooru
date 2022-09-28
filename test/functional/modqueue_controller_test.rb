require 'test_helper'

class ModqueueControllerTest < ActionDispatch::IntegrationTest
  context "The modqueue controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
      @post = create(:post, is_pending: true)
    end

    context "index action" do
      should "render" do
        get_auth modqueue_index_path, @admin
        assert_response :success
      end

      should "render for a json response" do
        get_auth modqueue_index_path, @admin, as: :json
        assert_response :success
      end

      should "support the only= URL param" do
        get_auth modqueue_index_path(only: "rating"), @admin, as: :json

        assert_response :success
        assert_equal([{ "rating" => @post.rating }], response.parsed_body)
      end

      should "include appealed posts in the modqueue" do
        @appeal = create(:post_appeal)
        get_auth modqueue_index_path, @admin

        assert_response :success
        assert_select "#post-#{@appeal.post_id}"
      end
    end
  end
end
