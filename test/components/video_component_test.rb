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
      assert_css(".shortcuts-help")
      assert_text("Mute")
      assert_text("Volume")
    end

    should "include the post's tags in video filenames when tagged_filenames is true" do
      post = create(:post, media_asset: build(:media_asset, file_ext: "mp4", duration: 30), tag_string: "touhou chen")
      Danbooru.config.stubs(:media_asset_file_url).returns("/untagged.mp4")
      Danbooru.config.stubs(:media_asset_file_url).with(anything, post.seo_tags).returns("/tagged.mp4")

      render_inline(VideoComponent.new(post.media_asset, tagged_filenames: true))

      assert_css("video.video-variant[src$='/tagged.mp4']")
      assert_no_css("video.video-variant[src$='/untagged.mp4']")
    end

    should "not include the post's tags in video filenames by default" do
      post = create(:post, media_asset: build(:media_asset, file_ext: "mp4", duration: 30), tag_string: "touhou chen")
      Danbooru.config.stubs(:media_asset_file_url).returns("/untagged.mp4")
      Danbooru.config.stubs(:media_asset_file_url).with(anything, post.seo_tags).returns("/tagged.mp4")

      render_inline(VideoComponent.new(post.media_asset))

      assert_css("video.video-variant[src$='/untagged.mp4']")
      assert_no_css("video.video-variant[src$='/tagged.mp4']")
    end

    should "not render the mute shortcut for soundless videos" do
      media_asset = create(:media_asset, file_ext: "mp4", duration: 30)

      render_inline(VideoComponent.new(media_asset))

      assert_css(".shortcuts-help")
      assert_no_text("Mute")
      assert_no_text("Volume")
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
