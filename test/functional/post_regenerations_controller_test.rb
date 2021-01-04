require 'test_helper'

class PostRegenerationsControllerTest < ActionDispatch::IntegrationTest
  context "The post regenerations controller" do
    setup do
      @mod = create(:moderator_user, name: "yukari", created_at: 1.month.ago)
      as(@mod) do
        @post = create(:post, source: "https://google.com", tag_string: "touhou")
      end
    end

    context "create action" do
      should "render" do
        post_auth post_regenerations_path, @mod, params: { post_id: @post.id, category: "iqdb" }
        assert_response :success
      end

      should "not allow non-mods to regenerate posts" do
        post_auth post_regenerations_path, create(:user), params: { post_id: @post.id, category: "iqdb" }
        assert_response 403
      end
    end
  end
end
