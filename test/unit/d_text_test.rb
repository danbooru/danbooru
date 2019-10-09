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
  end
end
