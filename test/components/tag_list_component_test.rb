require "test_helper"

class TagListComponentTest < ViewComponent::TestCase
  context "The TagListComponent" do
    setup do
      @arttag = create(:artist_tag)
      @copytag = create(:copyright_tag)
      @chartag = create(:character_tag)
      @gentag = create(:general_tag)
      @metatag = create(:meta_tag)
      @tags = Tag.all
    end

    context "for an inline tag list" do
      should "render" do
        render_inline(InlineTagListComponent.new(tags: @tags))

        assert_css(".inline-tag-list a.search-tag", count: 5)
      end
    end

    context "for a search tag list" do
      should "render" do
        render_inline(SearchTagListComponent.new(tags: @tags, current_query: "touhou"))

        assert_css(".search-tag-list li a.search-tag", count: 5)
      end
    end

    context "for a categorized tag list" do
      should "render" do
        render_inline(CategorizedTagListComponent.new(tags: @tags))

        assert_css(".categorized-tag-list li a.search-tag", count: 5)
        assert_css(".categorized-tag-list h3", count: 5)
      end
    end
  end
end
