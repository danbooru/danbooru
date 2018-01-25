require 'minitest/autorun'
require 'dtext/dtext'

class DTextTest < Minitest::Test
  def assert_parse(expected, input, **options)
    if expected.nil?
      assert_nil(DTextRagel.parse(input, **options))
    else
      assert_equal(expected, DTextRagel.parse(input, **options))
    end
  end

  def test_relative_urls
    assert_parse('<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="http://danbooru.donmai.us/posts/1234">post #1234</a></p>', "post #1234", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://danbooru.donmai.us/posts">posts</a></p>', '"posts":/posts', base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a rel="nofollow" href="http://danbooru.donmai.us/users?name=evazion">@evazion</a></p>', "@evazion", base_url: "http://danbooru.donmai.us")
  end

  def test_args
    assert_parse(nil, nil)
    assert_parse("", "")
    assert_raises(TypeError) { DTextRagel.parse(42) }
  end

  def test_mentions
    assert_parse('<p><a rel="nofollow" href="/users?name=bob">@bob</a></p>', "@bob")
    assert_parse('<p>hi <a rel="nofollow" href="/users?name=bob">@bob</a></p>', "hi @bob")
    assert_parse('<p>this is not @.@ @_@ <a rel="nofollow" href="/users?name=bob">@bob</a></p>', "this is not @.@ @_@ @bob")
    assert_parse('<p>this is an email@address.com and should not trigger</p>', "this is an email@address.com and should not trigger")
    assert_parse('<p>multiple <a rel="nofollow" href="/users?name=bob">@bob</a> <a rel="nofollow" href="/users?name=anna">@anna</a></p>', "multiple @bob @anna")
    assert_equal('<p>hi @bob</p>', DTextRagel.parse("hi @bob", :disable_mentions => true))
  end

  def test_nested_nonmention
    assert_parse('<p>foo <strong>idolm@ster</strong> bar</p>', 'foo [b]idolm@ster[/b] bar')
  end

  def test_sanitize_heart
    assert_parse('<p>&lt;3</p>', "<3")
  end

  def test_sanitize_less_than
    assert_parse('<p>&lt;</p>', "<")
  end

  def test_sanitize_greater_than
    assert_parse('<p>&gt;</p>', ">")
  end

  def test_sanitize_ampersand
    assert_parse('<p>&amp;</p>', "&")
  end

  def test_wiki_links
    assert_parse("<p>a <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=b\">b</a> c</p>", "a [[b]] c")
  end

  def test_wiki_links_spoiler
    assert_parse("<p>a <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=spoiler\">spoiler</a> c</p>", "a [[spoiler]] c")
  end

  def test_wiki_links_edge
    assert_parse("<p>[[|_|]]</p>", "[[|_|]]")
    assert_parse("<p>[[||_||]]</p>", "[[||_||]]")
  end

  def test_wiki_links_nested_b
    assert_parse("<p><strong>[[</strong>tag<strong>]]</strong></p>", "[b][[[/b]tag[b]]][/b]")
  end

  def test_spoilers_inline
    assert_parse("<p>this is <span class=\"spoiler\">an inline spoiler</span>.</p>", "this is [spoiler]an inline spoiler[/spoiler].")
  end

  def test_spoilers_inline_plural
    assert_parse("<p>this is <span class=\"spoiler\">an inline spoiler</span>.</p>", "this is [SPOILERS]an inline spoiler[/SPOILERS].")
  end

  def test_spoilers_block
    assert_parse("<p>this is</p><div class=\"spoiler\"><p>a block spoiler</p></div><p>.</p>", "this is\n\n[spoiler]\na block spoiler\n[/spoiler].")
  end

  def test_spoilers_block_plural
    assert_parse("<p>this is</p><div class=\"spoiler\"><p>a block spoiler</p></div><p>.</p>", "this is\n\n[SPOILERS]\na block spoiler\n[/SPOILERS].")
  end

  def test_spoilers_with_no_closing_tag_1
    assert_parse("<div class=\"spoiler\"><p>this is a spoiler with no closing tag</p><p>new text</p></div>", "[spoiler]this is a spoiler with no closing tag\n\nnew text")
  end

  def test_spoilers_with_no_closing_tag_2
    assert_parse("<div class=\"spoiler\"><p>this is a spoiler with no closing tag<br>new text</p></div>", "[spoiler]this is a spoiler with no closing tag\nnew text")
  end

  def test_spoilers_with_no_closing_tag_block
    assert_parse("<div class=\"spoiler\"><p>this is a block spoiler with no closing tag</p></div>", "[spoiler]\nthis is a block spoiler with no closing tag")
  end

  def test_spoilers_nested
    assert_parse("<div class=\"spoiler\"><p>this is <span class=\"spoiler\">a nested</span> spoiler</p></div>", "[spoiler]this is [spoiler]a nested[/spoiler] spoiler[/spoiler]")
  end

  def test_paragraphs
    assert_parse("<p>abc</p>", "abc")
  end

  def test_paragraphs_with_newlines_1
    assert_parse("<p>a<br>b<br>c</p>", "a\nb\nc")
  end

  def test_paragraphs_with_newlines_2
    assert_parse("<p>a</p><p>b</p>", "a\n\nb")
  end

  def test_headers
    assert_parse("<h1>header</h1>", "h1. header")
    assert_parse("<ul><li>a</li></ul><h1>header</h1><ul><li>list</li></ul>", "* a\n\nh1. header\n* list")
  end

  def test_inline_headers
    assert_parse("<p>blah h1. blah</p>", "blah h1. blah")
  end

  def test_headers_with_ids
    assert_parse("<h1 id=\"dtext-blah-blah\">header</h1>", "h1#blah-blah. header")
  end

  def test_headers_with_ids_with_quote
    assert_parse("<p>h1#blah-&quot;blah. header</p>", "h1#blah-\"blah. header")
  end

  def test_inline_tn
    assert_parse('<p>foo <span class="tn">bar</span></p>', "foo [tn]bar[/tn]")
  end

  def test_block_tn
    assert_parse('<p class="tn">bar</p>', "[tn]bar[/tn]")
  end

  def test_quote_blocks
    assert_parse('<blockquote><p>test</p></blockquote>', "[quote]\ntest\n[/quote]")
  end

  def test_quote_blocks_with_list
    assert_parse("<blockquote><ul><li>hello</li><li>there<br></li></ul></blockquote><p>abc</p>", "[quote]\n* hello\n* there\n[/quote]\nabc")
    assert_parse("<blockquote><ul><li>hello</li><li>there</li></ul></blockquote><p>abc</p>", "[quote]\n* hello\n* there\n\n[/quote]\nabc")
  end

  def test_quote_blocks_nested
    assert_parse("<blockquote><p>a</p><blockquote><p>b</p></blockquote><p>c</p></blockquote>", "[quote]\na\n[quote]\nb\n[/quote]\nc\n[/quote]")
  end

  def test_quote_blocks_nested_spoiler
    assert_parse("<blockquote><p>a<br><span class=\"spoiler\">blah</span><br>c</p></blockquote>", "[quote]\na\n[spoiler]blah[/spoiler]\nc[/quote]")
    assert_parse("<blockquote><p>a</p><div class=\"spoiler\"><p>blah</p></div><p>c</p></blockquote>", "[quote]\na\n\n[spoiler]blah[/spoiler]\n\nc[/quote]")
  end

  def test_quote_blocks_nested_expand
    assert_parse("<blockquote><p>a</p><div class=\"expandable\"><div class=\"expandable-header\"><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\"><p>b</p></div></div><p>c</p></blockquote>", "[quote]\na\n[expand]\nb\n[/expand]\nc\n[/quote]")
  end

  def test_code
    assert_parse("<pre>for (i=0; i&lt;5; ++i) {\n  printf(1);\n}\n\nexit(1);</pre>", "[code]for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);")
  end

  def test_urls
    assert_parse('<p>a <a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a> b</p>', 'a http://test.com b')
  end

  def test_urls_with_newline
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a><br>b</p>', "http://test.com\nb")
  end

  def test_urls_with_paths
    assert_parse('<p>a <a class="dtext-link dtext-external-link" href="http://test.com/~bob/image.jpg">http://test.com/~bob/image.jpg</a> b</p>', 'a http://test.com/~bob/image.jpg b')
  end

  def test_urls_with_fragment
    assert_parse('<p>a <a class="dtext-link dtext-external-link" href="http://test.com/home.html#toc">http://test.com/home.html#toc</a> b</p>', 'a http://test.com/home.html#toc b')
  end

  def test_auto_urls
    assert_parse('<p>a <a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>. b</p>', 'a http://test.com. b')
  end

  def test_auto_urls_in_parentheses
    assert_parse('<p>a (<a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>) b</p>', 'a (http://test.com) b')
  end

  def test_old_style_links
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com">test</a></p>', '"test":http://test.com')
  end

  def test_old_style_links_with_inline_tags
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com"><em>test</em></a></p>', '"[i]test[/i]":http://test.com')
  end

  def test_old_style_links_with_nested_links
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com">post #1</a></p>', '"post #1":http://test.com')
  end

  def test_old_style_links_with_special_entities
    assert_parse('<p>&quot;1&quot; <a class="dtext-link dtext-external-link" href="http://three.com">2 &amp; 3</a></p>', '"1" "2 & 3":http://three.com')
  end

  def test_new_style_links
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com">test</a></p>', '"test":[http://test.com]')
  end

  def test_new_style_links_with_inline_tags
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com/(parentheses)"><em>test</em></a></p>', '"[i]test[/i]":[http://test.com/(parentheses)]')
  end

  def test_new_style_links_with_nested_links
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com">post #1</a></p>', '"post #1":[http://test.com]')
  end

  def test_new_style_links_with_parentheses
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://test.com/(parentheses)">test</a></p>', '"test":[http://test.com/(parentheses)]')
    assert_parse('<p>(<a class="dtext-link dtext-external-link" href="http://test.com/(parentheses)">test</a>)</p>', '("test":[http://test.com/(parentheses)])')
    assert_parse('<p>[<a class="dtext-link dtext-external-link" href="http://test.com/(parentheses)">test</a>]</p>', '["test":[http://test.com/(parentheses)]]')
  end

  def test_fragment_only_urls
    assert_parse('<p><a class="dtext-link dtext-external-link" href="#toc">test</a></p>', '"test":#toc')
    assert_parse('<p><a class="dtext-link dtext-external-link" href="#toc">test</a></p>', '"test":[#toc]')
  end

  def test_auto_url_boundaries
    assert_parse('<p>a （<a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>） b</p>', 'a （http://test.com） b')
    assert_parse('<p>a 〜<a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>〜 b</p>', 'a 〜http://test.com〜 b')
    assert_parse('<p>a <a class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>　 b</p>', 'a http://test.com　 b')
  end

  def test_old_style_link_boundaries
    assert_parse('<p>a 「<a class="dtext-link dtext-external-link" href="http://test.com">title</a>」 b</p>', 'a 「"title":http://test.com」 b')
  end

  def test_new_style_link_boundaries
    assert_parse('<p>a 「<a class="dtext-link dtext-external-link" href="http://test.com">title</a>」 b</p>', 'a 「"title":[http://test.com]」 b')
  end

  def test_lists_1
    assert_parse('<ul><li>a</li></ul>', '* a')
  end

  def test_lists_2
    assert_parse('<ul><li>a</li><li>b</li></ul>', "* a\n* b")
  end

  def test_lists_nested
    assert_parse('<ul><li>a</li><ul><li>b</li></ul></ul>', "* a\n** b")
  end

  def test_lists_inline
    assert_parse('<ul><li><a class="dtext-link dtext-id-link dtext-post-id-link" href="/posts/1">post #1</a></li></ul>', "* post #1")
  end

  def test_lists_not_preceded_by_newline
    assert_parse('<p>a<br>b</p><ul><li>c</li><li>d</li></ul>', "a\nb\n* c\n* d")
  end

  def test_lists_with_multiline_items
    assert_parse('<p>a</p><ul><li>b<br>c</li><li>d<br>e</li></ul><p>another one</p>', "a\n* b\nc\n* d\ne\n\nanother one")
    assert_parse('<p>a</p><ul><li>b<br>c</li><ul><li>d<br>e</li></ul></ul><p>another one</p>', "a\n* b\nc\n** d\ne\n\nanother one")
  end

  def test_inline_tags
    assert_parse('<p><a rel="nofollow" class="dtext-link dtext-post-search-link" href="/posts?tags=tag">tag</a></p>', "{{tag}}")
    assert_parse('<p>hello <code>tag</code></p>', "hello [code]tag[/code]")
  end

  def test_inline_tags_conjunction
    assert_parse('<p><a rel="nofollow" class="dtext-link dtext-post-search-link" href="/posts?tags=tag1%20tag2">tag1 tag2</a></p>', "{{tag1 tag2}}")
  end

  def test_inline_tags_special_entities
    assert_parse('<p><a rel="nofollow" class="dtext-link dtext-post-search-link" href="/posts?tags=%3C3">&lt;3</a></p>', "{{<3}}")
  end

  def test_extra_newlines
    assert_parse('<p>a</p><p>b</p>', "a\n\n\n\n\n\n\nb\n\n\n\n")
  end

  def test_complex_links_1
    assert_parse("<p><a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=1\">2 3</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=4\">5 6</a></p>", "[[1|2 3]] | [[4|5 6]]")
  end

  def test_complex_links_2
    assert_parse("<p>Tags <strong>(<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=howto%3Atag\">Tagging Guidelines</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=howto%3Atag_checklist\">Tag Checklist</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/show_or_new?title=tag_groups\">Tag Groups</a>)</strong></p>", "Tags [b]([[howto:tag|Tagging Guidelines]] | [[howto:tag_checklist|Tag Checklist]] | [[Tag Groups]])[/b]")
  end

  def text_note_id_link
    assert_parse('<p><a class="dtext-link dtext-id-link dtext-note-id-link" href="/notes/1234">note #1234</a></p>', "note #1234")
  end

  def test_table
    assert_parse("<table class=\"striped\"><thead><tr><th>header</th></tr></thead><tbody><tr><td><a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/100\">post #100</a></td></tr></tbody></table>", "[table][thead][tr][th]header[/th][/tr][/thead][tbody][tr][td]post #100[/td][/tr][/tbody][/table]")
  end

  def test_table_with_newlines
    assert_parse("<table class=\"striped\"><thead><tr><th>header</th></tr></thead><tbody><tr><td><a class=\"dtext-link dtext-id-link dtext-post-id-link\" href=\"/posts/100\">post #100</a></td></tr></tbody></table>", "[table]\n[thead]\n[tr]\n[th]header[/th][/tr][/thead][tbody][tr][td]post #100[/td][/tr][/tbody][/table]")
  end

  def test_unclosed_th
    assert_parse('<table class="striped"><th>foo</th></table>', "[table][th]foo")
  end

  def test_forum_links
    assert_parse('<p><a class="dtext-link dtext-id-link dtext-forum-topic-id-link" href="/forum_topics/1234?page=4">topic #1234/p4</a></p>', "topic #1234/p4")
  end

  def test_boundary_exploit
    assert_parse('<p><a rel="nofollow" href="/users?name=mack">@mack</a>&lt;</p>', "@mack<")
  end

  def test_expand
    assert_parse("<div class=\"expandable\"><div class=\"expandable-header\"><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\"><p>hello world</p></div></div>", "[expand]hello world[/expand]")
  end

  def test_aliased_expand
    assert_parse("<div class=\"expandable\"><div class=\"expandable-header\"><span>hello</span><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\"><p>blah blah</p></div></div>", "[expand=hello]blah blah[/expand]")
  end

  def test_expand_with_nested_code
    assert_parse("<div class=\"expandable\"><div class=\"expandable-header\"><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\"><pre>hello\n</pre></div></div>", "[expand]\n[code]\nhello\n[/code]\n[/expand]")
  end

  def test_expand_with_nested_list
    assert_parse("<div class=\"expandable\"><div class=\"expandable-header\"><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\"><ul><li>a</li><li>b<br></li></ul></div></div><p>c</p>", "[expand]\n* a\n* b\n[/expand]\nc")
  end

  def test_inline_mode
    assert_equal("hello", DTextRagel.parse_inline("hello").strip)
  end

  def test_strip
    assert_equal("hellozworld", DTextRagel.parse_strip("h[b]e[/b]llo[quote]z[/quote]wo[expand]rld[/expand]"))
  end

  def test_old_asterisks
    assert_parse("<p>hello *world* neutral</p>", "hello *world* neutral")
  end

  def test_utf8_mentions
    assert_parse('<p><a rel="nofollow" href="/users?name=葉月">@葉月</a></p>', "@葉月")
    assert_parse('<p>Hello <a rel="nofollow" href="/users?name=葉月">@葉月</a> and <a rel="nofollow" href="/users?name=Alice">@Alice</a></p>', "Hello @葉月 and @Alice")
    assert_parse('<p>Should not parse 葉月@葉月</p>', "Should not parse 葉月@葉月")
  end

  def test_mention_boundaries
    assert_parse('<p>「hi <a rel="nofollow" href="/users?name=葉月">@葉月</a>」</p>', "「hi @葉月」")
  end

  def test_delimited_mentions
    dtext = '(blah <@evazion>).'
    html = '<p>(blah <a rel="nofollow" href="/users?name=evazion">@evazion</a>).</p>'
    assert_parse(html, dtext)
  end

  def test_utf8_links
    assert_parse('<p><a class="dtext-link dtext-external-link" href="/posts?tags=approver:葉月">7893</a></p>', '"7893":/posts?tags=approver:葉月')
    assert_parse('<p><a class="dtext-link dtext-external-link" href="/posts?tags=approver:葉月">7893</a></p>', '"7893":[/posts?tags=approver:葉月]')
    assert_parse('<p><a class="dtext-link dtext-external-link" href="http://danbooru.donmai.us/posts?tags=approver:葉月">http://danbooru.donmai.us/posts?tags=approver:葉月</a></p>', 'http://danbooru.donmai.us/posts?tags=approver:葉月')
  end

  def test_delimited_links
    dtext = '(blah <https://en.wikipedia.org/wiki/Orange_(fruit)>).'
    html = '<p>(blah <a class="dtext-link dtext-external-link" href="https://en.wikipedia.org/wiki/Orange_(fruit)">https://en.wikipedia.org/wiki/Orange_(fruit)</a>).</p>'
    assert_parse(html, dtext)
  end

  def test_nodtext
    assert_parse('<p>[b]not bold[/b]</p><p> <strong>bold</strong></p>', "[nodtext][b]not bold[/b][/nodtext] [b]bold[/b]")
    assert_parse('<p>[b]not bold[/b]</p><p><strong>hello</strong></p>', "[nodtext][b]not bold[/b][/nodtext]\n\n[b]hello[/b]")
    assert_parse('<p> [b]not bold[/b]</p>', " [nodtext][b]not bold[/b][/nodtext]")
  end

  def test_stack_depth_limit
    assert_raises(DTextRagel::Error) { DTextRagel.parse("* foo\n" * 513) }
  end

  def test_null_bytes
    assert_raises(DTextRagel::Error) { DTextRagel.parse("foo\0bar") }
  end

  def test_wiki_link_xss
    assert_raises(DTextRagel::Error) do
      DTextRagel.parse("[[\xFA<script \xFA>alert(42); //\xFA</script \xFA>]]")
    end
  end

  def test_mention_xss
    assert_raises(DTextRagel::Error) do
      DTextRagel.parse("@user\xF4<b>xss\xFA</b>")
    end
  end

  def test_url_xss
    assert_raises(DTextRagel::Error) do
      DTextRagel.parse(%("url":/page\xF4">x\xFA<b>xss\xFA</b>))
    end
  end
end
