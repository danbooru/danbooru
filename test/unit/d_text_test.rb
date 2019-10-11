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
      should "add tag types to wiki links" do
        create(:tag, name: "bkub", category: Tag.categories.artist, post_count: 42)
        assert_match(/tag-type-#{Tag.categories.artist}/, DText.format_text("[[bkub]]"))
      end

      should "mark links to nonexistent tags or wikis" do
        create(:tag, name: "no_wiki", post_count: 42)
        create(:tag, name: "empty_tag", post_count: 0)

        assert_match(/dtext-wiki-does-not-exist/, DText.format_text("[[no wiki]]"))
        assert_match(/dtext-tag-does-not-exist/, DText.format_text("[[no tag]]"))
        assert_match(/dtext-tag-empty/, DText.format_text("[[empty tag]]"))

        refute_match(/dtext-tag-does-not-exist/, DText.format_text("[[help:nothing]]"))
      end
    end
  end
end
