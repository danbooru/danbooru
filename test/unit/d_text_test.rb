require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def assert_strip_dtext(expected, dtext)
    assert_equal(expected, DText.new(dtext).strip_dtext)
  end

  def assert_rewrite_wiki_links(expected, dtext, old, new)
    assert_equal(expected, DText.new(dtext).rewrite_wiki_links(old, new).to_s)
  end

  def format_text(dtext, **options)
    DText.new(dtext, **options).format_text
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
      should "add tag types to wiki links" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, format_text("[[bkub]]"))
      end

      should "parse wiki links correctly when using an absolute base_url" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, format_text("[[bkub]]", base_url: "http://www.example.com"))
      end

      should "parse wiki links correctly when using an absolute base_url with a subdirectory" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, format_text("[[bkub]]", base_url: "http://www.example.com/danbooru"))
      end

      should "parse wiki links correctly when using a relative base_url" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, format_text("[[bkub]]", base_url: "/danbooru"))
      end

      should "convert direct links to short links" do
        assert_equal('<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a></p>', format_text("https://danbooru.donmai.us/posts/1234", domain: "danbooru.donmai.us"))
        assert_equal('<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a></p>', format_text("https://danbooru.donmai.us/posts/1234", domain: "danbooru.donmai.us", alternate_domains: ["betabooru.donmai.us"]))
        assert_equal('<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1234">post #1234</a></p>', format_text("https://danbooru.donmai.us/posts/1234", domain: "betabooru.donmai.us", alternate_domains: ["danbooru.donmai.us"]))

        assert_equal('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://danbooru.donmai.us/posts/1234">https://danbooru.donmai.us/posts/1234</a></p>', format_text("https://danbooru.donmai.us/posts/1234", domain: "betabooru.donmai.us"))
      end

      should "mark links to nonexistent tags or wikis" do
        create(:tag, name: "no_wiki", post_count: 42)
        create(:tag, name: "empty_tag", post_count: 0)

        assert_match(/dtext-wiki-does-not-exist/, format_text("[[no wiki]]"))
        assert_match(/dtext-tag-does-not-exist/, format_text("[[no tag]]"))
        assert_match(/dtext-tag-empty/, format_text("[[empty tag]]"))

        refute_match(/dtext-tag-does-not-exist/, format_text("[[help:nothing]]"))
      end

      should "parse [ta:<id>], [ti:<id>], [bur:<id>] pseudo tags" do
        @bur = create(:bulk_update_request, approver: create(:admin_user))
        @ti = create(:tag_implication)
        @ta = create(:tag_alias)

        BulkUpdateRequest::STATUSES.each do |status|
          @bur.update!(status: status)
          assert_match(/BUR ##{@bur.id}/, format_text("[bur:#{@bur.id}]"))
        end

        TagRelationship::STATUSES.each do |status|
          @ta.update!(status: status)
          @ti.update!(status: status)

          assert_match(/implication ##{@ti.id}/, format_text("[ti:#{@ti.id}]"))
          assert_match(/alias ##{@ta.id}/, format_text("[ta:#{@ta.id}]"))
        end
      end

      should "not parse [bur:<id>] tags inside [code] blocks" do
        assert_equal("<pre>[bur:1]</pre>", format_text("[code][bur:1][/code]"))
      end

      should "not fail if the [bur:<id>] tag has a bad id" do
        assert_equal("<p>bulk update request #0 does not exist.</p>", format_text("[bur:0]"))
        assert_equal('<p>tag <a class="dtext-link dtext-id-link dtext-tag-alias-id-link" href="/tag_aliases/0">alias #0</a> does not exist.</p>', format_text("[ta:0]"))
        assert_equal('<p>tag <a class="dtext-link dtext-id-link dtext-tag-implication-id-link" href="/tag_implications/0">implication #0</a> does not exist.</p>', format_text("[ti:0]"))
      end

      should "link artist tags to the artist page instead of the wiki page" do
        tag = create(:tag, name: "m&m", category: Tag.categories.artist)
        artist = create(:artist, name: "m&m")

        assert_equal('<p><a class="dtext-link dtext-wiki-link tag-type-1" href="/artists/show_or_new?name=m%26m">m&amp;m</a></p>', format_text("[[m&m]]"))
      end

      should "not link general tags to artist pages" do
        tag = create(:tag, name: "cat")
        artist = create(:artist, name: "cat", is_deleted: true)

        assert_match(%r!/wiki_pages/cat!, format_text("[[cat]]"))
      end
    end

    context "#wiki_titles" do
      should "parse wiki links in dtext" do
        assert_equal(["foo"], DText.new("[[foo]] [[FOO]").wiki_titles)
      end

      should "parse wiki links correctly when using a relative base url" do
        create(:tag, name: "bkub", category: Tag.categories.artist)

        assert_equal(["foo", "bkub"], DText.new("[[foo]] [[bkub]]", base_url: "/danbooru").wiki_titles)
      end

      should "parse wiki links inside [bur:id] tags" do
        create(:tag, name: "artist", category: Tag.categories.artist)
        @bur = create(:bulk_update_request, script: "alias bkubb -> bkub\nalias kitten -> cat\n\nalias kitty -> cat")

        assert_equal(%w[bkubb bkub kitten cat kitty], DText.new("[bur:#{@bur.id}]").wiki_titles)
      end
    end

    context "#external_links" do
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

        assert_equal(links, DText.new(dtext).external_links)
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

        assert_equal("<mailto:user@example.com>", DText.from_html('<a href="mailto:user@example.com">user@example.com</a>'))
        assert_equal('"user":[mailto:user@example.com]', DText.from_html('<a href="mailto:user@example.com">user</a>'))
      end

      should "not convert URLs with unsupported schemes to dtext links" do
        assert_equal("blah", DText.from_html('<a href="ftp://example.com">blah</a>'))
        assert_equal("blah", DText.from_html('<a href="file:///etc/password">blah</a>'))
        assert_equal("blah", DText.from_html('<a href="javascript:alert(1)">blah</a>'))
      end
    end

    context "#mentions" do
      should "parse mentions in dtext" do
        assert_equal(["foo", "bar"], DText.new("@foo @bar").mentions)
        assert_equal(["foo"], DText.new("@foo @FOO").mentions)
        assert_equal(["foo"], DText.new("(@foo)").mentions)
        assert_equal(["foo"], DText.new("<@foo>").mentions)
        assert_equal(["foo"], DText.new("@foo's").mentions)
        assert_equal(["foo"], DText.new("[nodtext][quote][/nodtext]@foo[nodtext][/quote][/nodtext]").mentions)

        assert_equal([], DText.new("[quote]@foo[/quote]").mentions)
        assert_equal([], DText.new("[nodtext]@foo[/nodtext]").mentions)
        assert_equal([], DText.new("[code]@foo[/code]").mentions)
        assert_equal([], DText.new("foo@bar.com").mentions)
        # assert_equal(["foo"], DText.new("@foo", disable_mentions: true).mentions) # XXX
      end
    end
  end
end
