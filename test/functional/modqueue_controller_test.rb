require 'test_helper'

class ModqueueControllerTest < ActionDispatch::IntegrationTest
  context "The modqueue controller" do
    setup do
      @admin = create(:admin_user)
      @user = create(:user)
      @post = as(@user) { create(:post, is_pending: true) }
    end

    context "index action" do
      should "render" do
        get_auth modqueue_index_path, @admin
        assert_response :success
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
