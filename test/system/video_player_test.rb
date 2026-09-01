require "application_system_test_case"

module VideoComponentTests
  extend ActiveSupport::Concern

  def main_video
    find("#image")
  end

  def embed_videos
    all(".dtext-media-embed .video-component").to_a
  end

  # Hover an element and wait for the browser to actually register the :hover state, since sending a global key press
  # right after `hover` isn't synchronized with it the way a normal Capybara action would be.
  def hover_and_wait(element)
    element.hover
    element.assert_matches_selector(:css, ":hover", wait: 5)
  end

  included do
    context "#{browser_name}:" do
      context "Video Player:" do
        setup do
          @user = create(:user, created_at: 1.month.ago)
          @post = create(:post_with_file, filename: "mp4/test-audio-ac3.mp4", tag_string: "1girl solo")
          @embed_post1 = create(:post_with_file, filename: "mp4/test-audio.mp4", tag_string: "1boy solo")
          @embed_post2 = create(:post_with_file, filename: "webm/test-audio.webm", tag_string: "2girls")

          create(:comment, creator: @user, post: @post, body: "!post ##{@embed_post1.id}")
          create(:comment, creator: @user, post: @post, body: "!post ##{@embed_post2.id}")

          visit post_path(@post)

          assert_selector "#image[data-state='ready']", wait: 10
          assert_selector ".dtext-media-embed .video-component", count: 2

          assert_selector ".dtext-media-embed .video-component[data-paused='false']", count: 2
        end

        should "load and play the video file" do
          assert_selector "#image video.video-variant"

          main_video.click if main_video["data-paused"] == "true"
          assert_selector "#image[data-paused='false']"
        end

        should "respond to the play/pause, seek, playback rate, volume, and mute shortcuts, even with other videos embedded on the page" do
          # Start from a known, paused state
          send_global_key(" ") if main_video["data-paused"] == "false"
          assert_selector "#image[data-paused='true']"

          send_global_key(" ")
          assert_selector "#image[data-paused='false']"

          send_global_key(" ")
          assert_selector "#image[data-paused='true']"

          # The number keys seek to a percentage of the video's duration.
          send_global_key("5")
          duration = main_video.find(".video-slider")["max"].to_f
          page.document.synchronize { (main_video.find(".video-slider").value.to_f - (duration * 0.5)).abs < 0.1 }

          send_global_key("0")
          page.document.synchronize { main_video.find(".video-slider").value.to_f < 0.1 }

          # The arrow keys seek forward/backward by 1% of the duration.
          time_before = main_video.find(".video-slider").value.to_f
          send_global_key("ArrowRight")
          page.document.synchronize { main_video.find(".video-slider").value.to_f > time_before }

          time_before = main_video.find(".video-slider").value.to_f
          send_global_key("ArrowLeft")
          page.document.synchronize { main_video.find(".video-slider").value.to_f < time_before }

          # < and > change the playback rate.
          assert_selector "#image[data-playback-rate='1']"
          send_global_key("<")
          assert_selector "#image[data-playback-rate='0.75']"
          send_global_key(">")
          send_global_key(">")
          assert_selector "#image[data-playback-rate='1.25']"

          # Up/down arrows change the volume, and m toggles mute.
          assert_selector "#image[data-muted='false']"
          send_global_key("ArrowDown")
          page.document.synchronize { (find("#image")["data-volume"].to_f - 0.9).abs < 0.02 }

          send_global_key("ArrowUp")
          page.document.synchronize { (find("#image")["data-volume"].to_f - 1.0).abs < 0.02 }

          # check that muting works
          send_global_key("m")
          assert_selector "#image[data-muted='true']"
          send_global_key("m")
          assert_selector "#image[data-muted='false']"
        end

        should "apply the shortcut to the hovered embed instead of the main video" do
          embed_selector = ".dtext-media-embed[data-id='#{@embed_post1.id}'] .video-component"
          other_embed_selector = ".dtext-media-embed[data-id='#{@embed_post2.id}'] .video-component"

          main_paused_before = main_video["data-paused"]
          main_paused_after = (main_paused_before == "true") ? "false" : "true"
          assert_selector "#{embed_selector}[data-paused='false']"
          assert_selector "#{other_embed_selector}[data-paused='false']"

          hover_and_wait(find(embed_selector))
          send_global_key(" ")

          assert_selector "#{embed_selector}[data-paused='true']", wait: 5 # hovering the embed should let the space bar pause it
          assert_selector "#image[data-paused='#{main_paused_before}']", wait: 5 # the main video shouldn't react to the shortcut while an embed is hovered
          assert_selector "#{other_embed_selector}[data-paused='false']", wait: 5 # the non-hovered embed shouldn't be affected

          # Un-hover the embed and confirm that the shortcut now applies to the main video again.
          find("body").hover
          find(embed_selector).assert_not_matches_selector(:css, ":hover", wait: 5)
          send_global_key(" ")

          assert_selector "#image[data-paused='#{main_paused_after}']", wait: 5 # the shortcut should apply to the main video once no embed is hovered
          assert_selector "#{embed_selector}[data-paused='true']", wait: 5 # the embed should stay paused
        end
      end
    end
  end
end

class VideoComponentChromeTest < ChromeSystemTestCase
  include VideoComponentTests
end

class VideoComponentFirefoxTest < FirefoxSystemTestCase
  include VideoComponentTests
end

class VideoComponentWebkitTest < WebkitSystemTestCase
  include VideoComponentTests
end
