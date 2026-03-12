require "test_helper"

class VideoComponentTest < ViewComponent::TestCase
  context "The VideoComponent" do
    should "render video variants and controls" do
      media_asset = create(:media_asset, file_ext: "mp4", duration: 30)
      media_asset.media_metadata.update!(metadata: { "FFmpeg:AudioPeakLoudness" => 0.1 })

      render_inline(VideoComponent.new(media_asset))

      assert_css(".video-component")
      assert_css(".video-component video.video-variant")
      assert_css(".video-component[data-has-sound='true']")
    end

    should "render ugoira variants" do
      media_asset = create(:media_asset, file_ext: "zip", duration: 2)
      media_asset.media_metadata.update!(metadata: { "Ugoira:FrameDelays" => [100, 200], "Ugoira:FrameOffsets" => [0, 1] })

      render_inline(VideoComponent.new(media_asset))

      assert_css(".video-component")
      assert_css("video.video-variant[data-variant='sample']")
      assert_css("canvas.video-variant[data-variant='original']")
    end
  end
end
