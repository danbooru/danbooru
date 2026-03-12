require "test_helper"

class CategorizedTagListComponentTest < ViewComponent::TestCase
  context "The CategorizedTagListComponent" do
    should "render tags grouped by category" do
      tags = [
        create(:tag, name: "sadamoto_yoshiyuki", category: Tag.categories.artist),
        create(:tag, name: "evangelion", category: Tag.categories.copyright),
        create(:tag, name: "ayanami_rei", category: Tag.categories.character),
        create(:tag, name: "blue_hair", category: Tag.categories.general),
        create(:tag, name: "commentary", category: Tag.categories.meta),
      ]

      render_inline(CategorizedTagListComponent.new(tags: tags))

      assert_css(".categorized-tag-list")
      assert_css("li[data-tag-name='sadamoto_yoshiyuki']")
      assert_css("li[data-tag-name='evangelion']")
      assert_css("li[data-tag-name='ayanami_rei']")
      assert_css("li[data-tag-name='blue_hair']")
      assert_css("li[data-tag-name='commentary']")
    end

    should "nest implied tags under each consequent" do
      evangelion = create(:tag, name: "evangelion", category: Tag.categories.copyright)
      ayanami_rei = create(:tag, name: "ayanami_rei", category: Tag.categories.character)
      evangelion_subtag = create(:tag, name: "neon_genesis_evangelion", category: Tag.categories.copyright)
      ayanami_rei_subtag = create(:tag, name: "ayanami_rei_(plugsuit)", category: Tag.categories.character)

      create(:tag_implication, antecedent_name: evangelion_subtag.name, consequent_name: evangelion.name, status: "active")
      create(:tag_implication, antecedent_name: ayanami_rei_subtag.name, consequent_name: ayanami_rei.name, status: "active")

      render_inline(CategorizedTagListComponent.new(tags: [evangelion, ayanami_rei, evangelion_subtag, ayanami_rei_subtag]))

      assert_css("li[data-tag-name='evangelion']", count: 1)
      assert_css("li[data-tag-name='neon_genesis_evangelion'].tag-nesting-level-1", count: 1)
      assert_css("li[data-tag-name='ayanami_rei']", count: 1)
      assert_css("li[data-tag-name='ayanami_rei_(plugsuit)'].tag-nesting-level-1", count: 1)
    end
  end
end
