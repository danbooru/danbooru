require "test_helper"

class SearchTagListComponentTest < ViewComponent::TestCase
  context "The SearchTagListComponent" do
    should "render search tags with counts" do
      tag = create(:tag, name: "blue_hair", category: Tag.categories.general, post_count: 42)

      render_inline(SearchTagListComponent.new(tags: [tag]))

      assert_css(".search-tag-list")
      assert_css("li[data-tag-name='blue_hair']")
      assert_css(".post-count", text: "42")
    end
  end
end
