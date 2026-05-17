require "test_helper"

class AutocompleteComponentTest < ViewComponent::TestCase
  context "The AutocompleteComponent" do
    should "render autocomplete results for a tag" do
      create(:tag, name: "blue_hair", category: Tag.categories.general, post_count: 123)
      service = AutocompleteService.new("blue", :tag)

      render_inline(AutocompleteComponent.new(autocomplete_service: service))

      assert_css(".ui-menu-item[data-autocomplete-value='blue_hair']")
      assert_css(".ui-menu-item b", text: "blue")
      assert_css(".post-count", text: "123")
    end

    should "render autocomplete results for an emoji" do
      Danbooru.config.stubs(:dtext_emojis).returns({ "smile" => "😄" })
      service = AutocompleteService.new("smi", :emoji)

      render_inline(AutocompleteComponent.new(autocomplete_service: service))

      assert_css(".ui-menu-item[data-autocomplete-value=':smile:']")
      assert_css(".ui-menu-item b", text: "smi")
    end
  end
end
