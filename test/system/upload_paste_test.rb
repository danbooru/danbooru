require "application_system_test_case"

# Pasting a URL anywhere on the upload page should fill in the source field and start the upload. Some apps copy links
# to the clipboard as a URL (text/uri-list) without any plain text, e.g. "Copy link" in the Pixiv app's share sheet on
# iOS. See https://github.com/danbooru/danbooru/issues/6793.
class UploadPasteWebkitTest < WebkitSystemTestCase
  # Fire a paste event on the upload page with the given clipboard contents, and return the source field's value afterwards.
  # Browsers don't let tests write to the real clipboard, so we build the paste event ourselves.
  #
  # @param data [Hash{String => String}] clipboard contents, as a hash of MIME type to value.
  def paste(data)
    page.evaluate_script(<<~JS)
      (() => {
        // Cancel the upload request so the test doesn't try to download the URL.
        $(".file-upload-component").on("ajax:before", () => false);

        let clipboardData = new DataTransfer();
        Object.entries(#{data.to_json}).forEach(([type, value]) => clipboardData.setData(type, value));
        document.body.dispatchEvent(new ClipboardEvent("paste", { clipboardData, bubbles: true, cancelable: true }));

        return $("input[name='upload[source]']").val();
      })()
    JS
  end

  context "Pasting a URL on the upload page" do
    setup do
      @user = create(:user, created_at: 1.month.ago)
      fast_signin @user
      visit new_upload_path
      assert_selector ".file-upload-component"
    end

    should "fill in the source when the clipboard contains plain text" do
      assert_equal "https://www.pixiv.net/en/artworks/140967231", paste("text/plain" => "https://www.pixiv.net/en/artworks/140967231")
    end

    should "fill in the source when the clipboard only contains a URL" do
      assert_equal "https://www.pixiv.net/en/artworks/140967231", paste("text/uri-list" => "https://www.pixiv.net/en/artworks/140967231")
    end
  end
end
