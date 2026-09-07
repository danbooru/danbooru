require "test_helper"

class TagTooltipComponentTest < ViewComponent::TestCase
  context "The TagTooltipComponent" do
    should "not show the embed if it's from an explicit post and safe mode is enabled" do
      explicit_post = create(:post, rating: "e")
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "A description.\n\n!post ##{explicit_post.id}")

      CurrentUser.set(safe_mode: true) do
        render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))
      end

      assert_css(".tag-tooltip")
      assert_no_css(".tag-tooltip-embed")
    end

    should "show the embed if it's from a general post" do
      general_post = create(:post, rating: "g")
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "A description.\n\n!post ##{general_post.id}")

      CurrentUser.set(safe_mode: true) do
        render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))
      end

      assert_css(".tag-tooltip")
      assert_css(".tag-tooltip-embed")
    end

    should "not show the embed for an artist wiki" do
      general_post = create(:post, rating: "g")
      tag = create(:artist_tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "A description.\n\n!post ##{general_post.id}")

      render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_css(".tag-tooltip")
      assert_no_css(".tag-tooltip-embed")
    end

    should "not show the embed if the wiki page has no meaningful text" do
      general_post = create(:post, rating: "g")
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "!post ##{general_post.id}")

      render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_css(".tag-tooltip")
      assert_no_css(".tag-tooltip-embed")
    end

    should "not show the missing wiki page message if the wiki page has no leading paragraph" do
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "h4. See Also\n* lmao")

      render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_no_text("This tag doesn't have a wiki page")
    end

    should "show that the tag is aliased instead of the missing wiki page message" do
      antecedent = create(:tag, name: "tohou", post_count: 1)
      consequent = create(:tag, name: "touhou", post_count: 1)
      create(:tag_alias, antecedent_name: antecedent.name, consequent_name: consequent.name)

      render_inline(TagTooltipComponent.new(tag: antecedent, current_user: create(:user)))

      assert_no_text("This tag doesn't have a wiki page")
      assert_text("This tag is aliased to touhou")
      assert_css(".tag-tooltip-text a.wiki-link[data-tag-name='touhou']")
    end
  end
end
