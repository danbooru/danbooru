require "test_helper"

class MediaAssetPreviewComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def render_preview(media_asset, **options)
    render_inline(MediaAssetPreviewComponent.new(media_asset: media_asset, **options))
  end

  context "The MediaAssetPreviewComponent" do
    context "for an image" do
      should "render the preview for each preview size" do
        media_asset = create(:media_asset)

        {
          150 => "180x180",
          180 => "180x180",
          225 => "360x360",
          270 => "360x360",
          360 => "360x360",
          540 => "720x720",
          720 => "720x720",
        }.each do |size, variant|
          node = render_preview(media_asset, size: size)

          assert_css("article.media-asset-preview-#{size}")
          assert_equal(media_asset_path(media_asset), node.css("article a").attr("href").value)
          assert_equal(media_asset.variant(variant).file_url, node.css("article img").attr("src").value)
        end
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

    context "for a flash file" do
      should "render the flash placeholder image" do
        media_asset = create(:media_asset, file_ext: "swf")
        node = render_preview(media_asset)

        assert_equal(media_asset_path(media_asset), node.css("article a").attr("href").value)
        assert_equal("images/flash-preview.png", node.css("article img").attr("src").value)
      end
    end

    context "for a processing asset" do
      should "render a placeholder" do
        media_asset = create(:media_asset, status: :processing)
        render_preview(media_asset)

        assert_css(".media-asset-placeholder")
        assert_no_css(".media-asset-preview-image")
      end
    end

    context "for a failed asset" do
      should "render a failed placeholder" do
        media_asset = create(:media_asset, status: :failed)
        render_preview(media_asset)

        assert_css(".media-asset-placeholder")
        assert_text("Failed")
      end
    end

    context "for a nil asset" do
      should "render a missing image placeholder" do
        render_preview(nil, link_target: "#")

        assert_css(".media-asset-placeholder")
        assert_text("No image")
      end
    end

    context "for an asset that isn't visible" do
      should "render a deleted placeholder" do
        media_asset = create(:media_asset, status: :deleted)
        render_preview(media_asset)

        assert_css(".media-asset-placeholder")
        assert_text("Deleted")
      end
    end
  end
end
