require 'test_helper'

class PostReplacementsControllerTest < ActionDispatch::IntegrationTest
  context "The post replacements controller" do
    setup do
      @mod = create(:moderator_user, name: "yukari", can_approve_posts: true, created_at: 1.month.ago)
      as(@mod) do
        @post = create(:post, source: "https://google.com", tag_string: "touhou")
        @post_replacement = create(:post_replacement, post: @post)
      end
    end

    context "create action" do
      should "render" do
        params = {
          format: :json,
          post_id: @post.id,
          post_replacement: {
            replacement_url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg"
          }
        }

        assert_difference("PostReplacement.count") do
          post_auth post_replacements_path, @mod, params: params
          assert_response :success
        end

        travel(PostReplacement::DELETION_GRACE_PERIOD + 1.day)
        perform_enqueued_jobs

        assert_equal("https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg", @post.reload.source)
        assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", @post.md5)
        assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", Digest::MD5.file(@post.file(:original)).hexdigest)
      end

      should "not allow non-mods to replace posts" do
        assert_difference("PostReplacement.count", 0) do
          post_auth post_replacements_path(post_id: @post.id), create(:user), params: { post_replacement: { replacement_url: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg" }}
          assert_response 403
        end
      end
    end

    context "update action" do
      should "update the replacement" do
        params = {
          format: :json,
          id: @post_replacement.id,
          post_replacement: {
            file_size_was: 23,
            file_size: 42
          }
        }

        put_auth post_replacement_path(@post_replacement), @mod, params: params
        assert_response :success
        assert_equal(23, @post_replacement.reload.file_size_was)
        assert_equal(42, @post_replacement.file_size)
      end
    end

    context "index action" do
      setup do
        as(create(:admin_user)) { @admin_replacement = create(:post_replacement, replacement_url: "https://danbooru.donmai.us") }
      end

      should "render" do
        get post_replacements_path
        assert_response :success
      end

      should respond_to_search({}).with { [@admin_replacement, @post_replacement] }
      should respond_to_search(replacement_url_like: "*danbooru*").with { @admin_replacement }

      context "using includes" do
        should respond_to_search(post_tags_match: "touhou").with { @post_replacement }
        should respond_to_search(creator: {level: User::Levels::ADMIN}).with { @admin_replacement }
        should respond_to_search(creator_name: "yukari").with { @post_replacement }
      end
    end
  end
end
