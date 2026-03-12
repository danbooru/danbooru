require "test_helper"

class InlineTagListComponentTest < ViewComponent::TestCase
  context "The InlineTagListComponent" do
    should "render inline tags for every category" do
      tags = [
        create(:tag, name: "sadamoto_yoshiyuki", category: Tag.categories.artist),
        create(:tag, name: "evangelion", category: Tag.categories.copyright),
        create(:tag, name: "ayanami_rei", category: Tag.categories.character),
        create(:tag, name: "blue_hair", category: Tag.categories.general),
        create(:tag, name: "commentary", category: Tag.categories.meta),
      ]

      render_inline(InlineTagListComponent.new(tags: tags))

      assert_css(".inline-tag-list")
      assert_css(".inline-tag-list .search-tag[data-tag-name='sadamoto_yoshiyuki']")
      assert_css(".inline-tag-list .search-tag[data-tag-name='evangelion']")
      assert_css(".inline-tag-list .search-tag[data-tag-name='ayanami_rei']")
      assert_css(".inline-tag-list .search-tag[data-tag-name='blue_hair']")
      assert_css(".inline-tag-list .search-tag[data-tag-name='commentary']")
    end
  end
end
