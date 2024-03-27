require "test_helper"

class MediaAssetLinkComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

  def render_component(media_asset, **options)
    render_inline(MediaAssetLinkComponent.new(media_asset: media_asset, **options))
  end

  context "The MediaAssetLinkComponent" do
    context "for an image" do
      should "render link" do
        media_asset = create(:media_asset, file_ext: "jpg")
        node = render_component(media_asset)
        text = "#{ActiveSupport::NumberHelper.number_to_human_size(media_asset.file_size)} .#{media_asset.file_ext}, " \
          "#{media_asset.image_width}x#{media_asset.image_height}"

        assert_equal(media_asset_path(media_asset), node.css("a").attr("href").value)
        assert_equal(text, node.css("a").text.squish)
      end
    end

    context "for a video" do
      should "render link with duration" do
        media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
        node = render_component(media_asset)
        text = "#{ActiveSupport::NumberHelper.number_to_human_size(media_asset.file_size)} .#{media_asset.file_ext}, " \
          "#{media_asset.image_width}x#{media_asset.image_height} " \
          "(#{Danbooru::Helpers.duration_to_hhmmss(media_asset.duration)})"

          assert_equal(media_asset_path(media_asset), node.css("a").attr("href").value)
          assert_equal(text, node.css("a").text.squish)
      end
    end
  end
end
