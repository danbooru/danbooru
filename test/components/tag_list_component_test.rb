require "test_helper"

class TagListComponentTest < ViewComponent::TestCase
  def render_tag_list(tags, variant, **options)
    with_variant(variant) do
      render_inline(TagListComponent.new(tags: tags, **options))
    end
  end

  context "The TagListComponent" do
    setup do
      @arttag = create(:artist_tag)
      @copytag = create(:copyright_tag)
      @chartag = create(:character_tag)
      @gentag = create(:general_tag)
      @metatag = create(:meta_tag)
      @tags = Tag.all
    end

    context "for a simple tag list" do
      should "render" do
        render_tag_list(@tags, :simple)

        assert_css(".simple-tag-list a.search-tag", count: 5)
      end
    end

    context "for an inline tag list" do
      should "render" do
        render_tag_list(@tags, :inline)

        assert_css(".inline-tag-list a.search-tag", count: 5)
      end
    end

    context "for a search tag list" do
      context "with +/- links" do
        should "render" do
          render_tag_list(@tags, :search, current_query: "touhou", show_extra_links: true)

          assert_css(".search-tag-list li a.search-tag", count: 5)
        end
      end

      context "without +/- links" do
        should "render" do
          render_tag_list(@tags, :search)

          assert_css(".search-tag-list li a.search-tag", count: 5)
        end
      end
    end

    context "for a categorized tag list" do
      should "render" do
        render_tag_list(@tags, :categorized)

        assert_css(".categorized-tag-list li a.search-tag", count: 5)
        assert_css(".categorized-tag-list h3", count: 5)
      end
    end
  end
end
