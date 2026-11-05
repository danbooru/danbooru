require "application_system_test_case"

class FlashPlayerChromeTest < ChromeSystemTestCase
  context "Flash player:" do
    setup do
      MediaAsset.stubs(:validate_media_file!)
      @post = create(:post_with_file, filename: "swf/compressed.swf")
    end

    should "play the file in a sandboxed iframe with an opaque origin" do
      visit post_path(@post)

      within_frame(find("iframe.flash-player")) do
        assert_selector "ruffle-player"
        assert_equal("null", evaluate_script("window.origin"))
        # readyState 2 means the SWF finished loading.
        page.document.synchronize { evaluate_script("document.querySelector('ruffle-player').readyState") == 2 or raise Capybara::ExpectationNotMet }
      end
    end
  end
end
