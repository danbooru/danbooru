require "test_helper"

class OpenGraphComponentTest < ViewComponent::TestCase
  context "The OpenGraphComponent" do
    should "render og image tags for images" do
      media_asset = create(:media_asset, file_ext: "jpg")
      node = render_inline(OpenGraphComponent.new(media_asset: media_asset, current_user: User.anonymous))

      assert_equal(media_asset.variant(:original).file_url, node.css("meta[property='og:image']").attr("content").value)
      assert_equal("summary_large_image", node.css("meta[name='twitter:card']").attr("content").value)
    end

    should "render og video tags for videos" do
      media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
      node = render_inline(OpenGraphComponent.new(media_asset: media_asset, current_user: User.anonymous))

      assert_equal(media_asset.variant(:"720x720").file_url, node.css("meta[property='og:image']").attr("content").value)
      assert_equal(media_asset.variant(:original).file_url, node.css("meta[property='og:video']").attr("content").value)
      assert_equal(media_asset.mime_type, node.css("meta[property='og:video:type']").attr("content").value)
      assert_equal("summary_large_image", node.css("meta[name='twitter:card']").attr("content").value)
    end

    should "not render tags when the asset isn't visible" do
      media_asset = create(:media_asset, file_ext: "jpg", status: :deleted)
      render_inline(OpenGraphComponent.new(media_asset: media_asset, current_user: User.anonymous))

      assert_no_css("meta[property='og:image']")
      assert_no_css("meta[property='og:video']")
      assert_no_css("meta[name='twitter:card']")
    end
  end
end
