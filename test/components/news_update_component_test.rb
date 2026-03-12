require "test_helper"

class NewsUpdateComponentTest < ViewComponent::TestCase
  context "The NewsUpdateComponent" do
    should "render the latest unseen news update" do
      create(:news_update, message: "Site notice")

      render_inline(NewsUpdateComponent.new(cookies: {}))

      assert_css("#news-updates")
      assert_text("Site notice")
    end
  end
end
