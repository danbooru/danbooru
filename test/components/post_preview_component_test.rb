require "test_helper"

class PostPreviewComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def render_preview(post, **options)
    render_inline(PostPreviewComponent.new(post: post, **options))
  end

  context "The PostPreviewComponent" do
    context "for a post visible to the current user" do
      should "render" do
        @post = create(:post)
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end
    end

    context "for a video post" do
      should "render" do
        @post = create(:post_with_file, filename: "test-512x512.webm").reload
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
        assert_equal("0:01", node.css("article .post-duration").text.strip)
      end
    end

    context "for a video post with sound" do
      should "render" do
        @post = create(:post_with_file, tag_string: "sound", filename: "test-audio.mp4").reload
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
        assert(node.css("article .sound-icon").present?)
      end
    end

    context "for a post with restricted tags" do
      setup do
        @post = create(:post, tag_string: "touhou")
      end

      should "should be visible to Gold users" do
        @post.stubs(:levelblocked?).returns(false)
        node = render_preview(@post, current_user: create(:gold_user))

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end

      should "not be visible to Members" do
        @post.stubs(:levelblocked?).returns(true)
        node = render_preview(@post, current_user: create(:user))
        assert_equal("", node.to_s)
      end
    end

    context "for a banned post" do
      setup do
        @post = create(:post, is_banned: true)
      end

      should "should only be visible to approvers" do
        node = render_preview(@post, current_user: create(:approver))

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end

      should "should be not visible to Gold users" do
        node = render_preview(@post, current_user: create(:gold_user))

        assert_equal("", node.to_s)
      end

      should "not be visible to Members" do
        node = render_preview(@post, current_user: create(:user))
        assert_equal("", node.to_s)
      end
    end

    context "for a banned paid reward" do
      setup do
        @post = create(:post, tag_string: "paid_reward", is_banned: true)
      end

      should "should be visible to Approver users" do
        node = render_preview(@post, current_user: create(:approver))

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end

      should "not be visible to Gold users" do
        node = render_preview(@post, current_user: create(:gold_user))
        assert_equal("", node.to_s)
      end
    end

    context "for a non-safe post" do
      setup do
        @post = create(:post, rating: "q")
      end

      should "should be visible to users with safe mode off" do
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end

      should "not be visible to users with safe mode on" do
        CurrentUser.stubs(:safe_mode?).returns(true)
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal("", node.to_s)
      end
    end

    context "for a deleted post" do
      setup do
        @post = create(:post, is_deleted: true)
      end

      should "should be visible when the show_deleted flag is set" do
        node = render_preview(@post, current_user: User.anonymous, show_deleted: true)

        assert_equal(post_path(@post), node.css("article a").attr("href").value)
        assert_equal(@post.media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end

      should "not be visible to users normally" do
        node = render_preview(@post, current_user: User.anonymous)

        assert_equal("", node.to_s)
      end
    end
  end
end
