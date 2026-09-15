require "test_helper"

class TagTooltipComponentTest < ViewComponent::TestCase
  include Rails.application.routes.url_helpers

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

    should "show the embed even if the wiki page has no meaningful text" do
      general_post = create(:post, rating: "g")
      tag = create(:tag, name: "touhou", post_count: 1)
      wiki_page = create(:wiki_page, title: tag.name, body: "!post ##{general_post.id}")

      node = render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_css(".tag-tooltip")
      assert_css(".tag-tooltip-embed")
      assert_equal(
        %{<p class="text-muted"> This tag has no description.<br> <a href="#{edit_wiki_page_path(wiki_page)}">Add one now</a>. </p>},
        node.css(".tag-tooltip-text").inner_html.squish,
      )
    end

    should "show text up to the first header" do
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "First paragraph.\n\nh4. See Also\n\nSecond paragraph.")

      node = render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_equal("<p>First paragraph.</p>", node.css(".tag-tooltip-text").inner_html.squish)
    end

    should "flatten multiple paragraphs into one block so line-clamp can clip precisely" do
      tag = create(:tag, name: "touhou", post_count: 1)
      create(:wiki_page, title: tag.name, body: "First paragraph.\n\nSecond paragraph.\n\nThird paragraph.")

      node = render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_equal(
        "<p>First paragraph.<br><br>Second paragraph.<br><br>Third paragraph.</p>",
        node.css(".tag-tooltip-text").inner_html.squish,
      )
    end

    should "show the no description message if the wiki page has no leading content" do
      tag = create(:tag, name: "touhou", post_count: 1)
      wiki_page = create(:wiki_page, title: tag.name, body: "h4. See Also\n* lmao")

      node = render_inline(TagTooltipComponent.new(tag: tag, current_user: create(:user)))

      assert_equal(
        %{<p class="text-muted"> This tag has no description.<br> <a href="#{edit_wiki_page_path(wiki_page)}">Add one now</a>. </p>},
        node.css(".tag-tooltip-text").inner_html.squish,
      )
    end

    should "show that the tag is aliased instead of the missing wiki page message" do
      antecedent = create(:tag, name: "tohou", post_count: 1)
      consequent = create(:tag, name: "touhou", post_count: 1)
      create(:tag_alias, antecedent_name: antecedent.name, consequent_name: consequent.name)

      node = render_inline(TagTooltipComponent.new(tag: antecedent, current_user: create(:user)))

      assert_equal(
        %{<p class="text-muted"> This tag is aliased to <a class="wiki-link tag-type-0 " data-tag-name="touhou" href="/wiki_pages/touhou">touhou</a>. </p>},
        node.css(".tag-tooltip-text").inner_html.squish,
      )
    end
  end
end
