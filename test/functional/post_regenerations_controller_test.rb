require 'test_helper'

class PostRegenerationsControllerTest < ActionDispatch::IntegrationTest
  context "The post regenerations controller" do
    setup do
      @mod = create(:moderator_user, name: "yukari", created_at: 1.month.ago)
      as(@mod) do
        @post = create(:post, source: "https://google.com", tag_string: "touhou")
        @post_regeneration = create(:post_regeneration, creator: @mod, category: "iqdb")
      end
    end

    context "create action" do
      should "render" do
        assert_difference("PostRegeneration.count") do
          post_auth post_regenerations_path, @mod, params: {format: :json, post_regeneration: {post_id: @post.id, category: "iqdb"}}
          assert_response :success
        end
      end

      should "not allow non-mods to regenerate posts" do
        assert_difference("PostRegeneration.count", 0) do
          post_auth post_regenerations_path, create(:user), params: {format: :json, post_regeneration: {post_id: @post.id, category: "iqdb"}}
          assert_response 403
        end
      end
    end

    context "index action" do
      setup do
        @admin = create(:admin_user)
        as(@admin) { @admin_regeneration = create(:post_regeneration, post: @post, creator: @admin, category: "resizes") }
      end

      should "render" do
        get post_regenerations_path
        assert_response :success
      end

      should respond_to_search({}).with { [@admin_regeneration, @post_regeneration] }
      should respond_to_search(category: "iqdb").with { @post_regeneration }

      context "using includes" do
        should respond_to_search(post_tags_match: "touhou").with { @admin_regeneration }
        should respond_to_search(creator: {level: User::Levels::ADMIN}).with { @admin_regeneration }
      end
    end
  end
end
