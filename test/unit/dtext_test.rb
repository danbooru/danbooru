require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def p(s)
    DText.parse(s)
  end

  def test_sanitize
    assert_equal('<p>&lt;</p>', p("<"))
    assert_equal('<p>&gt;</p>', p(">"))
    assert_equal('<p>&amp;</p>', p("&"))
  end

  def test_wiki_links
    assert_equal("<p>a <a href=\"/wiki_pages/show_or_new?title=b\">b</a> c</p>", p("a [[b]] c"))
    assert_equal("<p>a <a href=\"/wiki_pages/show_or_new?title=spoiler\">spoiler</a> c</p>", p("a [[spoiler]] c"))
  end

  def test_spoilers
    assert_equal("<p>this is <span class=\"spoiler\">an inline spoiler</span>.</p>", p("this is [spoiler]an inline spoiler[/spoiler]."))
    assert_equal("<p>this is</p><p><span class=\"spoiler\"><br>a block spoiler<br></span>.</p>", p("this is\n\n[spoiler]\na block spoiler\n[/spoiler]."))
    assert_equal("<p>[spoiler]this is a spoiler with no closing tag</p><p>new text</p>", p("[spoiler]this is a spoiler with no closing tag\n\nnew text"))
    assert_equal("<p>[spoiler]this is a spoiler with no closing tag<br>new text</p>", p("[spoiler]this is a spoiler with no closing tag\nnew text"))
    assert_equal("<p><span class=\"spoiler\">this is [spoiler]a nested</span> spoiler[/spoiler]</p>", p("[spoiler]this is [spoiler]a nested[/spoiler] spoiler[/spoiler]"))
  end

  def test_paragraphs
    assert_equal("<p>a</p>", p("a"))
    assert_equal("<p>abc</p>", p("abc"))
    assert_equal("<p>a<br>b<br>c</p>", p("a\nb\nc"))
    assert_equal("<p>a</p><p>b</p>", p("a\n\nb"))
  end

  def test_headers
    assert_equal("<h1>header</h1>", p("h1. header"))
    assert_equal("<h1>header</h1><p>paragraph</p>", p("h1.header\n\nparagraph"))
  end

  def test_quote_blocks
    assert_equal('<blockquote><p>test</p></blockquote>', p("[quote]\ntest\n[/quote]"))
    assert_equal("<blockquote>\n<p>a</p>\n<blockquote><p>b</p></blockquote>\n<p>c</p>\n</blockquote>", p("[quote]\na\n[quote]\nb\n[/quote]\nc\n[/quote]"))
  end

  def test_code
    assert_equal("<pre>for (i=0; i&lt;5; ++i) {\n  printf(1);\n}\n\nexit(1);\n\n</pre>", p("[code]for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);"))
  end

  def test_urls
    assert_equal('<p>a <a href="http://test.com">http://test.com</a> b</p>', p('a http://test.com b'))
    assert_equal('<p><a href="http://test.com">http://test.com</a><br>b</p>', p("http://test.com\nb"))
    assert_equal('<p>a <a href="http://test.com/~bob/image.jpg">http://test.com/~bob/image.jpg</a> b</p>', p('a http://test.com/~bob/image.jpg b'))
    assert_equal('<p>a <a href="http://test.com/home.html#toc">http://test.com/home.html#toc</a> b</p>', p('a http://test.com/home.html#toc b'))
    assert_equal('<p>a <a href="http://test.com">http://test.com</a>. b</p>', p('a http://test.com. b'))
    assert_equal('<p>a (<a href="http://test.com">http://test.com</a>) b</p>', p('a (http://test.com) b'))
  end
  
  def test_old_syle_links
    assert_equal('<p><a href="http://test.com">test</a></p>', p('"test":http://test.com'))
    assert_equal('<p>"1" <a href="http://two.com">2</a></p>', p('"1" "2":http://two.com'))
    assert_equal('<p>"1" <a href="http://three.com">2 &amp; 3</a></p>', p('"1" "2 & 3":http://three.com'))
  end

  def test_lists
    assert_equal('<ul><li>a</li></ul>', p('* a'))
    assert_equal('<ul><li>a</li><li>b</li></ul>', p("* a\n* b").gsub(/\n/, ""))
    assert_equal('<ul><li>a</li><ul><li>b</li></ul></ul>', p("* a\n** b").gsub(/\n/, ""))
    assert_equal('<ul><li><a href="/posts/1">post #1</a></li></ul>', p("* post #1").gsub(/\n/, ""))
  end

  def test_inline
    assert_equal('<p><a href="/posts?tags=tag">tag</a></p>', p("{{tag}}"))
    assert_equal('<p><a href="/posts?tags=tag1+tag2">tag1 tag2</a></p>', p("{{tag1 tag2}}"))
    assert_equal('<p><a href="/posts?tags=%3C3">&lt;3</a></p>', p("{{<3}}"))
  end

  def test_extra_newlines
    assert_equal('<p>a</p><p>b</p>', p("a\n\n\n\n\n\n\nb\n\n\n\n"))
  end

  def test_complex_links
    assert_equal("<p><a href=\"/wiki_pages/show_or_new?title=1\">2 3</a> | <a href=\"/wiki_pages/show_or_new?title=4\">5 6</a></p>", p("[[1|2 3]] | [[4|5 6]]"))
    assert_equal("<p>Tags <strong>(<a href=\"/wiki_pages/show_or_new?title=howto%3Atag\">Tagging Guidelines</a> | <a href=\"/wiki_pages/show_or_new?title=howto%3Atag_checklist\">Tag Checklist</a> | <a href=\"/wiki_pages/show_or_new?title=tag_groups\">Tag Groups</a>)</strong></p>", p("Tags [b]([[howto:tag|Tagging Guidelines]] | [[howto:tag_checklist|Tag Checklist]] | [[Tag Groups]])[/b]"))
  end
end
