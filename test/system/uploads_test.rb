require "application_system_test_case"

module UploadsTests
  extend ActiveSupport::Concern

  def upload_test_file
    attach_file(Rails.root.join("test/files/jpg/test.jpg").to_s) do
      find(".dropzone-container").click
    end

    assert_selector "#p-single-asset-upload", wait: 10
  end

  included do
    context "#{browser_name}:" do
      context "Uploads:" do
        setup do
          create(:tag, name: "1girl")
          @user = create(:user, favorite_tags: "1girl", created_at: 1.month.ago)
          fast_signin @user
          visit new_upload_path
        end

        should "upload a file and show the post form" do
          upload_test_file

          assert_selector "#form"
          assert_selector "input[type=radio][name='post[rating]']", visible: :all, minimum: 1
        end

        context "after uploading a file" do
          setup do
            upload_test_file
          end

          should "not submit the post without selecting a rating" do
            fill_in "post_tag_string", with: "1girl"

            click_button "Post"

            assert_selector "#p-single-asset-upload"
          end

          should "load the related tags and add a clicked tag to the tag box when clicked" do
            assert_selector "#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']"

            find("#related-tags-container .frequent-related-tags-column a[data-tag-name='1girl']").click

            assert_includes find_field("post_tag_string").value.split, "1girl"
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
      end
    end
  end
end

class UploadsChromeTest < ChromeSystemTestCase
  include UploadsTests
end

class UploadsFirefoxTest < FirefoxSystemTestCase
  include UploadsTests
end

class UploadsWebkitTest < WebkitSystemTestCase
  include UploadsTests
end
