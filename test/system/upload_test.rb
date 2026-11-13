require "application_system_test_case"

class UploadsChromeTest < ChromeSystemTestCase
  def upload_test_file
    attach_file(Rails.root.join("test/files/jpg/test.jpg").to_s) do
      find(".dropzone-container").click
    end

    assert_selector "#p-single-asset-upload"
  end

  context "Uploads:" do
    setup do
      create(:tag, name: "1girl")
      @user = create(:user, favorite_tags: "1girl", created_at: 1.month.ago)
      fast_signin @user
    end

    should "upload a file and show the post form" do
      visit new_upload_path
      upload_test_file

      assert_selector "#form"
      assert_selector "input[type=radio][name='post[rating]']", visible: :all, minimum: 1
    end

    should "show a clickable link to open an issue when uploading a webpage from an unsupported site" do
      perform_enqueued_jobs do
        visit new_upload_path
        fill_in "upload_source", with: "https://example.com"
        find("#upload_source").send_keys(:enter)

        assert_selector "#notice a[href='#{Danbooru.config.issues_url}/new'][target='_blank']", text: "GitHub"
      end
    end

    context "after uploading a file" do
      setup do
        @upload = create(:completed_file_upload, uploader: @user)
        visit upload_path(@upload)
      end

      should "load the related tags and add a clicked tag to the tag box when clicked" do
        assert_selector "#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']"

        find("#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']").click

        assert_includes find_field("post_tag_string").value.split, "1girl"
      end

      should "remove a related tag from the tag box when clicked again" do
        assert_selector "#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']"

        fill_in "post_tag_string", with: "1girls 1girl solo_1girl"
        find("#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']").click

        assert_equal "1girls solo_1girl ", find_field("post_tag_string").value
      end

      should "open the related tags header link in a new tab when ctrl+clicked" do
        fill_in "post_tag_string", with: "1girl"
        assert_selector ".related-tags-current-tag[href='/posts?tags=1girl']"

        window = window_opened_by { find(".related-tags-current-tag").click(:control) }
        within_window(window) { assert_current_path posts_path(tags: "1girl") }
      end

      should "not follow the related tags header link when clicked" do
        fill_in "post_tag_string", with: "1girl"
        assert_selector ".related-tags-current-tag[href='/posts?tags=1girl']"

        assert_no_navigation { find(".related-tags-current-tag").click }
      end

      should "move the edit panel when a dock option is clicked" do
        assert_no_navigation do
          find(".popup-menu:has(#dock-left-link) .popup-menu-button").click
          click_link "Dock to Left"
        end

        assert_selector ".upload-container[data-dock='left']"
      end

      should "show the rating help when the help icon is clicked" do
        assert_no_navigation { find(".help-tooltip-link").click }

        assert_selector ".tippy-box .help-tooltip-content"
      end

      should "load the iqdb results" do
        click_link "Similar"

        assert_visible "#iqdb-similar"
      end

      should "show the artist commentary fields under the Source tab" do
        click_link "Source"

        assert_selector "#post_artist_commentary_original_title"
        assert_selector "#post_artist_commentary_original_description"
      end
    end

    context "when the upload has multiple pixel-perfect duplicates" do
      should "open the Similar tab when the duplicate warning is clicked" do
        upload = create(:completed_file_upload, uploader: @user)
        2.times { create(:post, media_asset: build(:media_asset, pixel_hash: upload.media_assets.first.pixel_hash)) }
        visit upload_path(upload)

        click_link "Pixel-Perfect Duplicate"

        assert_selector ".tab-panel.similar-tab.active-tab"
        assert_selector "a.tab.similar-tab.active-tab"
        assert_current_path upload_path(upload)
      end
    end
  end
end
