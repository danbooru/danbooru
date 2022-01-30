require "test_helper"

class MediaAssetPreviewComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def render_preview(media_asset, **options)
    render_inline(MediaAssetPreviewComponent.new(media_asset: media_asset, **options))
  end

  context "The MediaAssetPreviewComponent" do
    context "for an image" do
      should "render the preview" do
        media_asset = create(:media_asset)
        node = render_preview(media_asset)

        assert_equal(media_asset_path(media_asset), node.css("article a").attr("href").value)
        assert_equal(media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
      end
    end

    context "for a video" do
      should "render the icon" do
        media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
        node = render_preview(media_asset)

        assert_equal(media_asset_path(media_asset), node.css("article a").attr("href").value)
        assert_equal(media_asset.variant("180x180").file_url, node.css("article img").attr("src").value)
        assert_equal("0:30", node.css("article .media-asset-duration").text.strip)
      end
    end
  end
end
