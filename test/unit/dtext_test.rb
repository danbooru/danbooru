require "test_helper"

class DTextTest < ActiveSupport::TestCase
  def p(s)
    DText.parse(s)
  end

  def test_mentions
    assert_equal('<p><a href="/users?name=bob">@bob</a></p>', p("@bob"))
    assert_equal('<p>hi <a href="/users?name=bob">@bob</a></p>', p("hi @bob"))
    assert_equal('<p>this is not @.@ @_@ <a href="/users?name=bob">@bob</a></p>', p("this is not @.@ @_@ @bob"))
    assert_equal('<p>multiple <a href="/users?name=bob">@bob</a> <a href="/users?name=anna">@anna</a></p>', p("multiple @bob @anna"))
  end

  def test_sanitize_heart
    assert_equal('<p>&lt;3</p>', p("<3"))
  end

  def test_sanitize_less_than
    assert_equal('<p>&lt;</p>', p("<"))
  end

  def test_sanitize_greater_than
    assert_equal('<p>&gt;</p>', p(">"))
  end

  def test_sanitize_ampersand
    assert_equal('<p>&amp;</p>', p("&"))
  end

  def test_wiki_links
    assert_equal("<p>a <a href=\"/wiki_pages/show_or_new?title=b\">b</a> c</p>", p("a [[b]] c"))
  end

  def test_wiki_links_spoiler
    assert_equal("<p>a <a href=\"/wiki_pages/show_or_new?title=spoiler\">spoiler</a> c</p>", p("a [[spoiler]] c"))
  end

  def test_spoilers_inline
    assert_equal("<p>this is</p><div class=\"spoiler\"><p>an inline spoiler</p></div><p>.</p>", p("this is [spoiler]an inline spoiler[/spoiler]."))
  end

  def test_spoilers_block
    assert_equal("<p>this is</p><div class=\"spoiler\"><p>a block spoiler</p></div><p>.</p>", p("this is\n\n[spoiler]\na block spoiler\n[/spoiler]."))
  end

  def test_spoilers_with_no_closing_tag_1
    assert_equal("<div class=\"spoiler\"><p>this is a spoiler with no closing tag</p><p>new text</p></div>", p("[spoiler]this is a spoiler with no closing tag\n\nnew text"))
  end

  def test_spoilers_with_no_closing_tag_2
    assert_equal("<div class=\"spoiler\"><p>this is a spoiler with no closing tag<br>new text</p></div>", p("[spoiler]this is a spoiler with no closing tag\nnew text"))
  end

  def test_spoilers_with_no_closing_tag_block
    assert_equal("<div class=\"spoiler\"><p>this is a block spoiler with no closing tag</p></div>", p("[spoiler]\nthis is a block spoiler with no closing tag"))
  end

  def test_spoilers_nested
    assert_equal("<div class=\"spoiler\"><p>this is</p><div class=\"spoiler\"><p>a nested</p></div><p>spoiler</p></div>", p("[spoiler]this is [spoiler]a nested[/spoiler] spoiler[/spoiler]"))
  end

  def test_paragraphs
    assert_equal("<p>abc</p>", p("abc"))
  end

  def test_paragraphs_with_newlines_1
    assert_equal("<p>a<br>b<br>c</p>", p("a\nb\nc"))
  end

  def test_paragraphs_with_newlines_2
    assert_equal("<p>a</p><p>b</p>", p("a\n\nb"))
  end

  def test_headers
    assert_equal("<h1>header</h1>", p("h1. header"))
  end
  
  def test_headers_with_ids
    assert_equal("<h1 id=\"dtext-header-id\">header</h1>", p("h1#header-id. header"))
  end

  def test_quote_blocks
    assert_equal('<blockquote><p>test</p></blockquote>', p("[quote]\ntest\n[/quote]"))
  end

  def test_quote_blocks_nested
    assert_equal("<blockquote><p>a</p><blockquote><p>b</p></blockquote><p>c</p></blockquote>", p("[quote]\na\n[quote]\nb\n[/quote]\nc\n[/quote]"))
  end

  def test_code
    assert_equal("<pre>for (i=0; i&lt;5; ++i) {\n  printf(1);\n}\n\nexit(1);\n\n</pre>", p("[code]for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);"))
  end

  def test_urls
    assert_equal('<p>a <a href="http://test.com">http://test.com</a> b</p>', p('a http://test.com b'))
  end

  def test_urls_with_newline
    assert_equal('<p><a href="http://test.com">http://test.com</a><br>b</p>', p("http://test.com\nb"))
  end

  def test_urls_with_paths
    assert_equal('<p>a <a href="http://test.com/~bob/image.jpg">http://test.com/~bob/image.jpg</a> b</p>', p('a http://test.com/~bob/image.jpg b'))
  end

  def test_urls_with_fragment
    assert_equal('<p>a <a href="http://test.com/home.html#toc">http://test.com/home.html#toc</a> b</p>', p('a http://test.com/home.html#toc b'))
  end

  def test_auto_urls
    assert_equal('<p>a <a href="http://test.com">http://test.com</a>. b</p>', p('a http://test.com. b'))
  end

  def test_auto_urls_in_parentheses
    assert_equal('<p>a (<a href="http://test.com">http://test.com</a>) b</p>', p('a (http://test.com) b'))
  end

  def test_old_style_links
    assert_equal('<p><a href="http://test.com">test</a></p>', p('"test":http://test.com'))
  end

  def test_old_style_links_with_special_entities
    assert_equal('<p>"1" <a href="http://three.com">2 &amp; 3</a></p>', p('"1" "2 & 3":http://three.com'))
  end

  def test_new_style_links
    assert_equal('<p><a href="http://test.com">test</a></p>', p('"test":[http://test.com]'))
  end

  def test_new_style_links_with_parentheses
    assert_equal('<p><a href="http://test.com/(parentheses)">test</a></p>', p('"test":[http://test.com/(parentheses)]'))
    assert_equal('<p>(<a href="http://test.com/(parentheses)">test</a>)</p>', p('("test":[http://test.com/(parentheses)])'))
    assert_equal('<p>[<a href="http://test.com/(parentheses)">test</a>]</p>', p('["test":[http://test.com/(parentheses)]]'))
  end

  def test_lists_1
    assert_equal('<ul><li>a</li></ul>', p('* a'))
  end

  def test_lists_2
    assert_equal('<ul><li>a</li><li>b</li></ul>', p("* a\n* b").gsub(/\n/, ""))
  end

  def test_lists_nested
    assert_equal('<ul><li>a</li><ul><li>b</li></ul></ul>', p("* a\n** b").gsub(/\n/, ""))
  end

  def test_lists_inline
    assert_equal('<ul><li><a href="/posts/1">post #1</a></li></ul>', p("* post #1").gsub(/\n/, ""))
  end

  def test_lists_not_preceded_by_newline
    assert_equal('<p>ab</p><ul><li>c</li><li>d</li></ul>', p("a\nb\n* c\n* d").gsub(/\n/, ""))
  end

  def test_lists_with_multiline_items
    assert_equal('<p>a</p><ul><li>bc</li><li>de</li></ul>', p("a\n* b\nc\n* d\ne").gsub(/\n/, ""))
  end

  def test_inline_tags
    assert_equal('<p><a rel="nofollow" href="/posts?tags=tag">tag</a></p>', p("{{tag}}"))
  end

  def test_inline_tags_conjunction
    assert_equal('<p><a rel="nofollow" href="/posts?tags=tag1+tag2">tag1 tag2</a></p>', p("{{tag1 tag2}}"))
  end

  def test_inline_tags_special_entities
    assert_equal('<p><a rel="nofollow" href="/posts?tags=%3C3">&lt;3</a></p>', p("{{<3}}"))
  end

  def test_extra_newlines
    assert_equal('<p>a</p><p>b</p>', p("a\n\n\n\n\n\n\nb\n\n\n\n"))
  end

  def test_complex_links_1
    assert_equal("<p><a href=\"/wiki_pages/show_or_new?title=1\">2 3</a> | <a href=\"/wiki_pages/show_or_new?title=4\">5 6</a></p>", p("[[1|2 3]] | [[4|5 6]]"))
  end

  def test_complex_links_2
    assert_equal("<p>Tags <strong>(<a href=\"/wiki_pages/show_or_new?title=howto%3Atag\">Tagging Guidelines</a> | <a href=\"/wiki_pages/show_or_new?title=howto%3Atag_checklist\">Tag Checklist</a> | <a href=\"/wiki_pages/show_or_new?title=tag_groups\">Tag Groups</a>)</strong></p>", p("Tags [b]([[howto:tag|Tagging Guidelines]] | [[howto:tag_checklist|Tag Checklist]] | [[Tag Groups]])[/b]"))
  end

  def test_table
    assert_equal("<table class=\"striped\"><thead><tr><th>header</th></tr></thead><tbody><tr><td><a href=\"/posts/100\">post #100</a></td></tr></tbody></table>", p("[table][thead][tr][th]header[/th][/tr][/thead][tbody][tr][td]post #100[/td][/tr][/tbody][/table]"))
  end

  def test_table_with_newlines
    assert_equal("<table class=\"striped\"><thead>\n<tr>\n<th>header</th></tr></thead><tbody><tr><td><a href=\"/posts/100\">post #100</a></td></tr></tbody></table>", p("[table]\n[thead]\n[tr]\n[th]header[/th][/tr][/thead][tbody][tr][td]post #100[/td][/tr][/tbody][/table]"))
  end

  def test_forum_links
    assert_equal('<p><a href="/forum_topics/1234?page=4">topic #1234/p4</a></p>', p("topic #1234/p4"))
  end
end
