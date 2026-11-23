require "application_system_test_case"

class BookmarkletChromeTest < ChromeSystemTestCase
  context "The bookmarklet page" do
    should "explain how to install the bookmarklet when the bookmarklet link is clicked" do
      visit bookmarklet_path

      assert_no_navigation { click_link "Post to #{Danbooru.config.app_name}" }
      assert_notice "Drag this link to your bookmarks toolbar."
    end
  end
end
