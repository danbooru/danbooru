require "test_helper"

class MediaAssetComponentTest < ViewComponent::TestCase
  def render_component(media_asset, **options)
    render_inline(MediaAssetComponent.new(media_asset: media_asset, **options))
  end

  context "The MediaAssetComponent" do
    context "for an image" do
      should "render the image" do
        media_asset = create(:media_asset, file_ext: "jpg")
        node = render_component(media_asset)

        assert_equal(media_asset.variant(:original).file_url, node.css(".media-asset-component img").attr("src").value)
      end
    end

    context "for a video" do
      should "render the video" do
        media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
        node = render_component(media_asset)

        assert_equal(media_asset.variant(:original).file_url, node.css(".media-asset-component video").attr("src").value)
      end
    end

    context "for a ugoira" do
      should "render the ugoira" do
        media_asset = create(:media_asset, file_ext: "zip")
        node = render_component(media_asset)

        assert_equal(media_asset.variant(:sample).file_url, node.css(".media-asset-component video").attr("src").value)
      end
    end

    context "for a flash file" do
      should "render the flash" do
        media_asset = create(:media_asset, file_ext: "swf")
        node = render_component(media_asset)

        assert_equal(media_asset.variant(:original).file_url, node.css(".media-asset-component div.ruffle-container").attr("data-swf").value)
      end
    end
  end
end
