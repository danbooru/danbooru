require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def assert_strip_dtext(expected, dtext)
    assert_equal(expected, DText.strip_dtext(dtext))
  end

  def assert_rewrite_wiki_links(expected, dtext, old, new)
    assert_equal(expected, DText.rewrite_wiki_links(dtext, old, new))
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

      should "link artist tags to the artist page instead of the wiki page" do
        tag = create(:tag, name: "m&m", category: Tag.categories.artist)
        artist = create(:artist, name: "m&m")

        assert_equal(
          '<p><a class="dtext-link dtext-wiki-link tag-type-1" href="/artists/show_or_new?name=m%26m">m&amp;m</a></p>',
          DText.format_text("[[m&m]]")
        )
      end

      should "not link general tags to artist pages" do
        tag = create(:tag, name: "cat")
        artist = create(:artist, name: "cat", is_deleted: true)

        assert_match(%r!/wiki_pages/cat!, DText.format_text("[[cat]]"))
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

    context "#rewrite_wiki_links" do
      should "work" do
        assert_rewrite_wiki_links("[[rabbit]]", "[[bunny]]", "bunny", "rabbit")
        assert_rewrite_wiki_links("[[rabbit|bun]]", "[[bunny|bun]]", "bunny", "rabbit")

        assert_rewrite_wiki_links("[[cat]] [[rabbit]]", "[[cat]] [[rabbit]]", "bunny", "rabbit")
        assert_rewrite_wiki_links("I like [[cat]]s and [[bunny]]s", "I like [[cat]]s and [[rabbit]]s", "rabbit", "bunny")

        assert_rewrite_wiki_links("[[miku hatsune (cosplay)|]]", "[[hatsune miku (cosplay)]]", "hatsune_miku_(cosplay)", "miku_hatsune_(cosplay)")
        assert_rewrite_wiki_links("[[Miku hatsune (cosplay)|]]", "[[Hatsune miku (cosplay)]]", "hatsune_miku_(cosplay)", "miku_hatsune_(cosplay)")
        assert_rewrite_wiki_links("[[Miku Hatsune (cosplay)|]]", "[[Hatsune Miku (cosplay)]]", "hatsune_miku_(cosplay)", "miku_hatsune_(cosplay)")
        assert_rewrite_wiki_links("[[miku hatsune (cosplay)|miku]]", "[[hatsune miku (cosplay)|miku]]", "hatsune_miku_(cosplay)", "miku_hatsune_(cosplay)")

        assert_rewrite_wiki_links("[[the legend of zelda]]", "[[zelda no densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[The legend of zelda]]", "[[Zelda no densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[The Legend Of Zelda]]", "[[Zelda No Densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[the legend of zelda]]", "[[zelda_no_densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[The legend of zelda]]", "[[Zelda_no_densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[The Legend Of Zelda]]", "[[Zelda_No_Densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")

        assert_rewrite_wiki_links("[[Zelda no Densetsu]]", "[[Zelda no Densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")
        assert_rewrite_wiki_links("[[Zelda_no_Densetsu]]", "[[Zelda_no_Densetsu]]", "zelda_no_densetsu", "the_legend_of_zelda")

        assert_rewrite_wiki_links("[[Mario (series)|]]", "[[Mario]]", "mario", "mario_(series)")
      end
    end

    context "#from_html" do
      should "convert basic html to dtext" do
        assert_equal("[b]abc[/b] [i]def[/i] [u]ghi[/u]", DText.from_html("<b>abc</b> <i>def</i> <u>ghi</u>"))
      end

      should "convert links to dtext" do
        assert_equal('"example":[https://www.example.com]', DText.from_html('<a href="https://www.example.com">example</a>'))
        assert_equal("<https://www.example.com>", DText.from_html('<a href="https://www.example.com">https://www.example.com</a>'))
      end
    end
  end
end
