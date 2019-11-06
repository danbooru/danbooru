require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def assert_strip_dtext(expected, dtext)
    assert_equal(expected, DText.strip_dtext(dtext))
  end

  context "DText" do
    context "#strip_dtext" do
      should "strip dtext markup from the input" do
        assert_strip_dtext("x", "[b]x[/b]")
        assert_strip_dtext("x", "[i]x[/i]")
        assert_strip_dtext("x", "[tn]x[/tn]")
        assert_strip_dtext("x", "[spoilers]x[/spoilers]")

        assert_strip_dtext("post #123", "post #123")
        assert_strip_dtext("pixiv #123", "pixiv #123")

        assert_strip_dtext("bkub", "{{bkub}}")
        assert_strip_dtext("bkub", "[[bkub]]")
        assert_strip_dtext("Bkub", "[[bkub|Bkub]]")

        assert_strip_dtext("http://www.example.com", "http://www.example.com")
        assert_strip_dtext("http://www.example.com", "<http://www.example.com>")
        assert_strip_dtext("x", '"x":/posts')
        assert_strip_dtext("x", '"x":[/posts]')

        assert_strip_dtext("@bkub", "@bkub")
        assert_strip_dtext("@bkub", "<@bkub>")

        assert_strip_dtext("x", "h1. x")
        assert_strip_dtext("x", "h2. [i]x[/i]")

        assert_strip_dtext("* one\n* two", "* [b]one[/b]\n* [[two]]")
        assert_strip_dtext("okay", "[expand][u]okay[/u][/expand]")
        assert_strip_dtext("> chen said:\n> \n> honk honk", "[quote]chen said:\n\nhonk honk[/quote]")

        assert_strip_dtext("one two three\nfour\n\nfive six", "one [b]two[/b] three\nfour\n\nfive six")
      end
    end

    context "#format_text" do
      setup do
        CurrentUser.user = create(:user)
        CurrentUser.ip_addr = "127.0.0.1"
      end

      teardown do
        CurrentUser.user = nil
        CurrentUser.ip_addr = nil
      end

      should "add tag types to wiki links" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, DText.format_text("[[bkub]]"))
      end

      should "parse wiki links correctly with the base_url option" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, DText.format_text("[[bkub]]", base_url: "http://www.example.com"))
      end

      should "mark links to nonexistent tags or wikis" do
        create(:tag, name: "no_wiki", post_count: 42)
        create(:tag, name: "empty_tag", post_count: 0)

        assert_match(/dtext-wiki-does-not-exist/, DText.format_text("[[no wiki]]"))
        assert_match(/dtext-tag-does-not-exist/, DText.format_text("[[no tag]]"))
        assert_match(/dtext-tag-empty/, DText.format_text("[[empty tag]]"))

        refute_match(/dtext-tag-does-not-exist/, DText.format_text("[[help:nothing]]"))
      end

      should "parse [ta:<id>], [ti:<id>], [bur:<id>] pseudo tags" do
        @bur = create(:bulk_update_request)
        @ti = create(:tag_implication)
        @ta = create(:tag_alias)

        assert_match(/bulk update request/, DText.format_text("[bur:#{@bur.id}]"))
        assert_match(/implication ##{@ti.id}/, DText.format_text("[ti:#{@ti.id}]"))
        assert_match(/alias ##{@ta.id}/, DText.format_text("[ta:#{@ta.id}]"))
      end
    end

    context "#parse_wiki_titles" do
      should "parse wiki links in dtext" do
        assert_equal(["foo"], DText.parse_wiki_titles("[[foo]] [[FOO]"))
      end
    end

    context "#parse_external_links" do
      should "parse external links in dtext" do
        dtext = <<~EOS
          * https://test1.com
          * <https://test2.com>
          * "test":https://test3.com
          * "test":[https://test4.com]
          * [https://test5.com](test)
          * <a href="https://test6.com">test</a>
        EOS

        links = %w[
          https://test1.com https://test2.com https://test3.com
          https://test4.com https://test5.com https://test6.com
        ]

        assert_equal(links, DText.parse_external_links(dtext))
      end
    end
  end
end
