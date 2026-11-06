require "test_helper"

class DtextPreviewsControllerTest < ActionDispatch::IntegrationTest
  context "The dtext previews controller" do
    context "create action" do
      setup do
        @user = create(:user)
      end

      should "render" do
        post_auth dtext_preview_path, @user, params: { body: "h1. Touhou\n\n* [[touhou]]" }
        assert_response :success
      end

      should "reject an overlong body" do
        post_auth dtext_preview_path, @user, params: { body: "a" * ForumPost::MAX_BODY_LENGTH }
        assert_response :success

        post_auth dtext_preview_path, @user, params: { body: "a" * (ForumPost::MAX_BODY_LENGTH + 1) }
        assert_response 422
      end

      should "not allow anonymous users" do
        post dtext_preview_path, params: { body: "test" }
        assert_response 403
      end

      should "be rate limited" do
        user = create(:user)
        Danbooru.config.stubs(:rate_limits_enabled?).returns(true)
        create(:rate_limit, action: "dtext_previews:create", key: user.cache_key, limited: true)

        post_auth dtext_preview_path, user, params: { body: "test" }

        assert_response 429
      end
    end
  end
end
