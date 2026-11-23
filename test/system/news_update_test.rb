require "application_system_test_case"

class NewsUpdateChromeTest < ChromeSystemTestCase
  context "A news update" do
    should "be hidden when closed, and stay hidden on later page loads" do
      create(:news_update, message: "Site notice")
      visit posts_path

      assert_visible "#news-updates", text: "Site notice"

      assert_no_navigation { find("#news-updates a").click }
      assert_hidden "#news-updates"

      visit posts_path
      assert_no_selector "#news-updates"
    end
  end
end
