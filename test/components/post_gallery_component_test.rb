require "test_helper"

class PostGalleryComponentTest < ViewComponent::TestCase
  context "The PostGalleryComponent" do
    should "render post previews inside a grid gallery" do
      post = create(:post)

      render_inline(PostGalleryComponent.new) do |gallery|
        gallery.with_post(post: post, current_user: User.anonymous)
      end

      assert_css(".post-gallery")
      assert_css(".post-gallery-grid")
      assert_css(".post-gallery article")
    end

    should "render post previews inside an inline gallery" do
      post = create(:post)

      render_inline(PostGalleryComponent.new(inline: true)) do |gallery|
        gallery.with_post(post: post, current_user: User.anonymous)
      end

      assert_css(".post-gallery")
      assert_css(".post-gallery-inline")
      assert_css(".post-gallery article")
    end

    should "render an empty gallery message" do
      render_inline(PostGalleryComponent.new)

      assert_css(".post-gallery")
      assert_css("p", text: "No posts found.")
    end
  end
end
