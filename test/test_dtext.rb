# frozen_string_literal: true

require "dtext"
require "cgi"
require "minitest/autorun"

class DTextTest < Minitest::Test
  def parse(*args, **options)
    DText.parse(*args, **options)
  end

  def parse_inline(dtext)
    parse(dtext, inline: true)
  end

  def assert_parse_id_link(class_name, url, input)
    if url[0] == "/"
      assert_parse(%{<p><a class="dtext-link dtext-id-link #{class_name}" href="#{url}">#{input}</a></p>}, input)
      assert_parse(%{<p><a class="dtext-link dtext-id-link #{class_name}" href="http://danbooru.donmai.us#{url}">#{input}</a></p>}, input, base_url: "http://danbooru.donmai.us")
    else
      assert_parse(%{<p><a rel="external nofollow noreferrer" class="dtext-link dtext-id-link #{class_name}" href="#{url}">#{input}</a></p>}, input)
      assert_parse(%{<p><a rel="external nofollow noreferrer" class="dtext-link dtext-id-link #{class_name}" href="#{url}">#{input}</a></p>}, input, base_url: "http://danbooru.donmai.us")
    end
  end

  def assert_parse(expected, input, **options)
    if expected.nil?
      assert_nil(parse(input, **options))
    else
      assert_equal(expected, parse(input, **options))
    end
  end

  def assert_inline_parse(expected, input)
    assert_parse(expected, input, inline: true)
  end

  def test_relative_urls
    assert_parse('<p><a class="dtext-link dtext-id-link dtext-post-id-link" href="http://danbooru.donmai.us/posts/1234">post #1234</a></p>', "post #1234", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="http://danbooru.donmai.us/wiki_pages/touhou">touhou</a></p>', "[[touhou]]", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="http://danbooru.donmai.us/wiki_pages/touhou">Touhou</a></p>', "[[touhou|Touhou]]", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-post-search-link" href="http://danbooru.donmai.us/posts?tags=touhou">touhou</a></p>', "{{touhou}}", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-id-link dtext-forum-topic-id-link" href="http://danbooru.donmai.us/forum_topics/1234?page=4">topic #1234/p4</a></p>', "topic #1234/p4", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="http://danbooru.donmai.us/posts">home</a></p>', '"home":/posts', base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="http://danbooru.donmai.us#posts">home</a></p>', '"home":#posts', base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="http://danbooru.donmai.us/posts">home</a></p>', '<a href="/posts">home</a>', base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="http://danbooru.donmai.us#posts">home</a></p>', '<a href="#posts">home</a>', base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-user-mention-link" data-user-name="evazion" href="http://danbooru.donmai.us/users?name=evazion">@evazion</a></p>', "@evazion", base_url: "http://danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link dtext-user-mention-link" data-user-name="evazion" href="http://danbooru.donmai.us/users?name=evazion">@evazion</a></p>', "<@evazion>", base_url: "http://danbooru.donmai.us")
  end

  def test_args
    assert_parse(nil, nil)
    assert_parse("", "")
    assert_raises(TypeError) { parse(42) }
  end

  def test_mentions
    assert_parse('<p><a class="dtext-link dtext-user-mention-link" data-user-name="bob" href="/users?name=bob">@bob</a></p>', "@bob")
    assert_parse('<p>hi <a class="dtext-link dtext-user-mention-link" data-user-name="bob" href="/users?name=bob">@bob</a></p>', "hi @bob")
    assert_parse('<p>this is not @.@ @_@ <a class="dtext-link dtext-user-mention-link" data-user-name="bob" href="/users?name=bob">@bob</a></p>', "this is not @.@ @_@ @bob")
    assert_parse('<p>this is an email@address.com and should not trigger</p>', "this is an email@address.com and should not trigger")
    assert_parse('<p>multiple <a class="dtext-link dtext-user-mention-link" data-user-name="bob" href="/users?name=bob">@bob</a> <a class="dtext-link dtext-user-mention-link" data-user-name="anna" href="/users?name=anna">@anna</a></p>', "multiple @bob @anna")
    assert_equal('<p>hi @bob</p>', parse("hi @bob", :disable_mentions => true))
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
    assert_parse("<p>a <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/b\">b</a> c</p>", "a [[b]] c")
  end

  def test_wiki_links_spoiler
    assert_parse("<p>a <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/spoiler\">spoiler</a> c</p>", "a [[spoiler]] c")
  end

  def test_wiki_links_edge
    assert_parse("<p>[[|_|]]</p>", "[[|_|]]")
    assert_parse("<p>[[||_||]]</p>", "[[||_||]]")
  end

  def test_wiki_links_nested_b
    assert_parse("<p><strong>[[</strong>tag<strong>]]</strong></p>", "[b][[[/b]tag[b]]][/b]")
  end

  def test_wiki_links_suffixes
    assert_parse('<p>I like <a class="dtext-link dtext-wiki-link" href="/wiki_pages/cat">cats</a>.</p>', "I like [[cat]]s.")
    assert_parse('<p>a <a class="dtext-link dtext-wiki-link" href="/wiki_pages/cat">cat</a>\'s paw</p>', "a [[cat]]'s paw")
    assert_parse('<p>the <a class="dtext-link dtext-wiki-link" href="/wiki_pages/60s">1960s</a>.</p>', "the 19[[60s]].")
    assert_parse('<p>a <a class="dtext-link dtext-wiki-link" href="/wiki_pages/c">bcd</a> e</p>', "a b[[c]]d e")

    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/b">acd</a></p>', "a[[b|c]]d")
  end

  def test_wiki_links_pipe_trick
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/tagme">tagme</a></p>', "[[tagme|]]")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/tagme">TAGME</a></p>', "[[TAGME|]]")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/foo_%28bar%29">foo</a></p>', "[[foo (bar)|]]")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/foo_%28bar%29">abcfoo123</a></p>', "abc[[foo (bar)|]]123")

    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/kaga_%28kantai_collection%29">kaga</a></p>', "[[kaga_(kantai_collection)|]]")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/kaga_%28kantai_collection%29">Kaga</a></p>', "[[Kaga (Kantai Collection)|]]")
    assert_parse('<p><a class="dtext-link dtext-wiki-link" href="/wiki_pages/kaga_%28kantai_collection%29_%28cosplay%29">kaga (kantai collection)</a></p>', "[[kaga (kantai collection) (cosplay)|]]")
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

  def test_inline_elements
    assert_inline_parse("<strong>foo</strong>", "[b]foo[/b]")
    assert_inline_parse("<strong>foo</strong>", "<b>foo</b>")
    assert_inline_parse("<strong>foo</strong>", "<strong>foo</strong>")

    assert_inline_parse("<em>foo</em>", "[i]foo[/i]")
    assert_inline_parse("<em>foo</em>", "<i>foo</i>")
    assert_inline_parse("<em>foo</em>", "<em>foo</em>")

    assert_inline_parse("<s>foo</s>", "[s]foo[/s]")
    assert_inline_parse("<s>foo</s>", "<s>foo</s>")

    assert_inline_parse("<u>foo</u>", "[u]foo[/u]")
    assert_inline_parse("<u>foo</u>", "<u>foo</u>")
  end

  def test_inline_tn
    assert_parse('<p>foo <span class="tn">bar</span> baz</p>', "foo [tn]bar[/tn] baz")
    assert_parse('<p>foo <span class="tn">bar</span> baz</p>', "foo <tn>bar</tn> baz")
  end

  def test_block_tn
    assert_parse('<p class="tn">bar</p>', "[tn]bar[/tn]")
    assert_parse('<p class="tn">bar</p>', "<tn>bar</tn>")
  end

  def test_quote_blocks
    assert_parse('<blockquote><p>test</p></blockquote>', "[quote]\ntest\n[/quote]")
    assert_parse('<blockquote><p>test</p></blockquote>', "<quote>\ntest\n</quote>")
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
    assert_parse("<blockquote><p>a</p><details><summary>Show</summary><div><p>b</p></div></details><p>c</p></blockquote>", "[quote]\na\n[expand]\nb\n[/expand]\nc\n[/quote]")
  end

  def test_block_code
    assert_parse("<pre>for (i=0; i&lt;5; ++i) {\n  printf(1);\n}\n\nexit(1);</pre>", "[code]for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);")
    assert_parse("<pre>[b]lol[/b]</pre>", "[code][b]lol[/b][/code]")
    assert_parse("<pre>[code]</pre>", "[code][code][/code]")
    assert_parse("<pre>post #123</pre>", "[code]post #123[/code]")
    assert_parse("<pre>x</pre>", "[code]x")
  end

  def test_inline_code
    assert_parse("<p>foo <code>[b]lol[/b]</code>.</p>", "foo [code][b]lol[/b][/code].")
    assert_parse("<p>foo <code>[code]</code>.</p>", "foo [code][code][/code].")
    assert_parse("<p>foo <em><code>post #123</code></em>.</p>", "foo [i][code]post #123[/code][/i].")
    assert_parse("<p>foo <code>x</code></p>", "foo [code]x")
  end

  def test_urls
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a> b</p>', 'a http://test.com b')
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="Http://test.com">Http://test.com</a> b</p>', 'a Http://test.com b')
  end

  def test_urls_with_newline
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a><br>b</p>', "http://test.com\nb")
  end

  def test_urls_with_paths
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com/~bob/image.jpg">http://test.com/~bob/image.jpg</a> b</p>', 'a http://test.com/~bob/image.jpg b')
  end

  def test_urls_with_fragment
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com/home.html#toc">http://test.com/home.html#toc</a> b</p>', 'a http://test.com/home.html#toc b')
  end

  def test_auto_urls
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>. b</p>', 'a http://test.com. b')
  end

  def test_auto_urls_in_parentheses
    assert_parse('<p>a (<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>) b</p>', 'a (http://test.com) b')
  end

  def test_internal_links
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">https://danbooru.donmai.us</a></p>', 'https://danbooru.donmai.us', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://danbooru.donmai.us">https://danbooru.donmai.us</a></p>', 'https://danbooru.donmai.us', domain: "testbooru.donmai.us")

    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">https://danbooru.donmai.us</a></p>', 'https://danbooru.donmai.us', domain: "danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>', 'https://danbooru.donmai.us/login', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>', 'https://danbooru.donmai.us/login', domain: "testbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>', 'https://danbooru.donmai.us/login', domain: "")

    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">https://danbooru.donmai.us</a></p>', '<https://danbooru.donmai.us>', domain: "danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>', '<https://danbooru.donmai.us/login>', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://danbooru.donmai.us/login">https://danbooru.donmai.us/login</a></p>', '<https://danbooru.donmai.us/login>', domain: "testbooru.donmai.us")

    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">home</a></p>', '"home":https://danbooru.donmai.us', domain: "danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us/login">login</a></p>', '"login":https://danbooru.donmai.us/login', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="https://danbooru.donmai.us/login">login</a></p>', '"login":https://danbooru.donmai.us/login', domain: "testbooru.donmai.us")

    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">home</a></p>', '"home":[https://danbooru.donmai.us]', domain: "danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us/login">login</a></p>', '"login":[https://danbooru.donmai.us/login]', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="https://danbooru.donmai.us/login">login</a></p>', '"login":[https://danbooru.donmai.us/login]', domain: "testbooru.donmai.us")

    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us">home</a></p>', '[https://danbooru.donmai.us](home)', domain: "danbooru.donmai.us")
    assert_parse('<p><a class="dtext-link" href="https://danbooru.donmai.us/login">login</a></p>', '[https://danbooru.donmai.us/login](login)', domain: "danbooru.donmai.us")
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="https://danbooru.donmai.us/login">login</a></p>', '[https://danbooru.donmai.us/login](login)', domain: "testbooru.donmai.us")

    assert_parse('<p><a class="dtext-link" href="https://user:pass@danbooru.donmai.us:80">https://user:pass@danbooru.donmai.us:80</a></p>', 'https://user:pass@danbooru.donmai.us:80', domain: "danbooru.donmai.us")
  end

  def test_old_style_links
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">test</a></p>', '"test":http://test.com')
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="Http://test.com">test</a></p>', '"test":Http://test.com')

    assert_parse('<p><a class="dtext-link" href="#">test</a></p>', '"test":#')
    assert_parse('<p><a class="dtext-link" href="/">test</a></p>', '"test":/')
    assert_parse('<p><a class="dtext-link" href="/x">test</a></p>', '"test":/x')
    assert_parse('<p><a class="dtext-link" href="//">test</a></p>', '"test"://')

    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://example.com">test</a></p>', '"test"://example.com')
  end

  def test_old_style_links_with_inline_tags
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com"><em>test</em></a></p>', '"[i]test[/i]":http://test.com')
  end

  def test_old_style_links_with_nested_links
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">post #1</a></p>', '"post #1":http://test.com')
  end

  def test_old_style_links_with_special_entities
    assert_parse('<p>&quot;1&quot; <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://three.com">2 &amp; 3</a></p>', '"1" "2 & 3":http://three.com')
  end

  def test_new_style_links
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">test</a></p>', '"test":[http://test.com]')
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="Http://test.com">test</a></p>', '"test":[Http://test.com]')

    assert_parse('<p><a class="dtext-link" href="#">test</a></p>', '"test":[#]')
    assert_parse('<p><a class="dtext-link" href="/">test</a></p>', '"test":[/]')
    assert_parse('<p><a class="dtext-link" href="/x">test</a></p>', '"test":[/x]')
    assert_parse('<p><a class="dtext-link" href="//">test</a></p>', '"test":[//]')

    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://example.com">test</a></p>', '"test":[//example.com]')
  end

  def test_new_style_links_with_inline_tags
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com/(parentheses)"><em>test</em></a></p>', '"[i]test[/i]":[http://test.com/(parentheses)]')
  end

  def test_new_style_links_with_nested_links
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">post #1</a></p>', '"post #1":[http://test.com]')
  end

  def test_new_style_links_with_parentheses
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com/(parentheses)">test</a></p>', '"test":[http://test.com/(parentheses)]')
    assert_parse('<p>(<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com/(parentheses)">test</a>)</p>', '("test":[http://test.com/(parentheses)])')
    assert_parse('<p>[<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com/(parentheses)">test</a>]</p>', '["test":[http://test.com/(parentheses)]]')
  end

  def test_markdown_links
    assert_inline_parse('<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://example.com">test</a>', '[http://example.com](test)')
    assert_inline_parse('<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="Http://example.com">test</a>', '[Http://example.com](test)')
    assert_inline_parse('<em>one</em>(two)', '[i]one[/i](two)')

    assert_inline_parse(CGI.escapeHTML('[blah](test)'), '[blah](test)')
    assert_inline_parse(CGI.escapeHTML('[](test)'), '[](test)')
  end

  def test_html_links
    assert_inline_parse('<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://example.com">test</a>', '<a href="http://example.com">test</a>')
    assert_inline_parse('<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="Http://example.com">test</a>', '<a href="Http://example.com">test</a>')
    assert_inline_parse('<a class="dtext-link" href="/x">a <em>b</em> c</a>', '<a href="/x">a [i]b[/i] c</a>')

    assert_parse('<p><a class="dtext-link" href="#">test</a></p>', '<a href="#">test</a>')
    assert_parse('<p><a class="dtext-link" href="/">test</a></p>', '<a href="/">test</a>')
    assert_parse('<p><a class="dtext-link" href="/x">test</a></p>', '<a href="/x">test</a>')
    assert_parse('<p><a class="dtext-link" href="//">test</a></p>', '<a href="//">test</a>')
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://x">test</a></p>', '<a href="//x">test</a>')
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://evil.com">test</a></p>', '<a href="//evil.com">test</a>')

    assert_inline_parse(CGI.escapeHTML('<a href="">test</a>'), '<a href="">test</a>')
    assert_inline_parse(CGI.escapeHTML('<a id="foo" href="">test</a>'), '<a id="foo" href="">test</a>')
  end

  def test_fragment_only_urls
    assert_parse('<p><a class="dtext-link" href="#toc">test</a></p>', '"test":#toc')
    assert_parse('<p><a class="dtext-link" href="#toc">test</a></p>', '"test":[#toc]')
  end

  def test_auto_url_boundaries
    assert_parse('<p>a （<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>） b</p>', 'a （http://test.com） b')
    assert_parse('<p>a 〜<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>〜 b</p>', 'a 〜http://test.com〜 b')
    assert_parse('<p>a <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://test.com">http://test.com</a>　 b</p>', 'a http://test.com　 b')
  end

  def test_old_style_link_boundaries
    assert_parse('<p>a 「<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">title</a>」 b</p>', 'a 「"title":http://test.com」 b')
  end

  def test_new_style_link_boundaries
    assert_parse('<p>a 「<a rel="external nofollow noreferrer" class="dtext-link dtext-external-link dtext-named-external-link" href="http://test.com">title</a>」 b</p>', 'a 「"title":[http://test.com]」 b')
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
    assert_parse('<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=tag">tag</a></p>', "{{tag}}")
    assert_parse('<p>hello <code>tag</code></p>', "hello [code]tag[/code]")
  end

  def test_inline_tags_conjunction
    assert_parse('<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=tag1%20tag2">tag1 tag2</a></p>', "{{tag1 tag2}}")
    assert_parse('<p><a class="dtext-link dtext-post-search-link" href="https://danbooru.donmai.us/posts?tags=tag1%20tag2">tag1 tag2</a></p>', "{{tag1 tag2}}", base_url: "https://danbooru.donmai.us")
  end

  def test_inline_tags_special_entities
    assert_parse('<p><a class="dtext-link dtext-post-search-link" href="/posts?tags=%3C3">&lt;3</a></p>', "{{<3}}")
  end

  def test_extra_newlines
    assert_parse('<p>a</p><p>b</p>', "a\n\n\n\n\n\n\nb\n\n\n\n")
  end

  def test_complex_links_1
    assert_parse("<p><a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/~1\">2 3</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/~4\">5 6</a></p>", "[[1|2 3]] | [[4|5 6]]")
  end

  def test_complex_links_2
    assert_parse("<p>Tags <strong>(<a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/howto%3Atag\">Tagging Guidelines</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/howto%3Atag_checklist\">Tag Checklist</a> | <a class=\"dtext-link dtext-wiki-link\" href=\"/wiki_pages/tag_groups\">Tag Groups</a>)</strong></p>", "Tags [b]([[howto:tag|Tagging Guidelines]] | [[howto:tag_checklist|Tag Checklist]] | [[Tag Groups]])[/b]")
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

  def test_id_links
    assert_parse_id_link("dtext-post-id-link", "/posts/1234", "post #1234")
    assert_parse_id_link("dtext-post-appeal-id-link", "/post_appeals/1234", "appeal #1234")
    assert_parse_id_link("dtext-post-flag-id-link", "/post_flags/1234", "flag #1234")
    assert_parse_id_link("dtext-note-id-link", "/notes/1234", "note #1234")
    assert_parse_id_link("dtext-forum-post-id-link", "/forum_posts/1234", "forum #1234")
    assert_parse_id_link("dtext-forum-topic-id-link", "/forum_topics/1234", "topic #1234")
    assert_parse_id_link("dtext-comment-id-link", "/comments/1234", "comment #1234")
    assert_parse_id_link("dtext-pool-id-link", "/pools/1234", "pool #1234")
    assert_parse_id_link("dtext-user-id-link", "/users/1234", "user #1234")
    assert_parse_id_link("dtext-artist-id-link", "/artists/1234", "artist #1234")
    assert_parse_id_link("dtext-ban-id-link", "/bans/1234", "ban #1234")
    assert_parse_id_link("dtext-tag-alias-id-link", "/tag_aliases/1234", "alias #1234")
    assert_parse_id_link("dtext-tag-implication-id-link", "/tag_implications/1234", "implication #1234")
    assert_parse_id_link("dtext-favorite-group-id-link", "/favorite_groups/1234", "favgroup #1234")
    assert_parse_id_link("dtext-mod-action-id-link", "/mod_actions/1234", "mod action #1234")
    assert_parse_id_link("dtext-user-feedback-id-link", "/user_feedbacks/1234", "feedback #1234")
    assert_parse_id_link("dtext-wiki-page-id-link", "/wiki_pages/1234", "wiki #1234")
    assert_parse_id_link("dtext-moderation-report-id-link", "/moderation_reports/1234", "modreport #1234")
    assert_parse_id_link("dtext-dmail-id-link", "/dmails/1234", "dmail #1234")

    assert_parse_id_link("dtext-github-id-link", "https://github.com/danbooru/danbooru/issues/1234", "issue #1234")
    assert_parse_id_link("dtext-github-pull-id-link", "https://github.com/danbooru/danbooru/pull/1234", "pull #1234")
    assert_parse_id_link("dtext-github-commit-id-link", "https://github.com/danbooru/danbooru/commit/1234", "commit #1234")
    assert_parse_id_link("dtext-artstation-id-link", "https://www.artstation.com/artwork/A1", "artstation #A1")
    assert_parse_id_link("dtext-deviantart-id-link", "https://www.deviantart.com/deviation/1234", "deviantart #1234")
    assert_parse_id_link("dtext-nijie-id-link", "https://nijie.info/view.php?id=1234", "nijie #1234")
    assert_parse_id_link("dtext-pawoo-id-link", "https://pawoo.net/web/statuses/1234", "pawoo #1234")
    assert_parse_id_link("dtext-pixiv-id-link", "https://www.pixiv.net/artworks/1234", "pixiv #1234")
    assert_parse_id_link("dtext-pixiv-id-link", "https://www.pixiv.net/artworks/1234#2", "pixiv #1234/p2")
    assert_parse_id_link("dtext-seiga-id-link", "https://seiga.nicovideo.jp/seiga/im1234", "seiga #1234")
    assert_parse_id_link("dtext-twitter-id-link", "https://twitter.com/i/web/status/1234", "twitter #1234")

    assert_parse_id_link("dtext-yandere-id-link", "https://yande.re/post/show/1234", "yandere #1234")
    assert_parse_id_link("dtext-sankaku-id-link", "https://chan.sankakucomplex.com/post/show/1234", "sankaku #1234")
    assert_parse_id_link("dtext-gelbooru-id-link", "https://gelbooru.com/index.php?page=post&s=view&id=1234", "gelbooru #1234")
  end

  def test_dmail_key_id_link
    assert_parse(%{<p><a class="dtext-link dtext-id-link dtext-dmail-id-link" href="/dmails/1234?key=abc%3D%3D--DEF123">dmail #1234</a></p>}, "dmail #1234/abc==--DEF123")
    assert_parse(%{<p><a class="dtext-link dtext-id-link dtext-dmail-id-link" href="http://danbooru.donmai.us/dmails/1234?key=abc%3D%3D--DEF123">dmail #1234</a></p>}, "dmail #1234/abc==--DEF123", base_url: "http://danbooru.donmai.us")
  end

  def test_boundary_exploit
    assert_parse('<p><a class="dtext-link dtext-user-mention-link" data-user-name="mack" href="/users?name=mack">@mack</a>&lt;</p>', "@mack<")
  end

  def test_expand
    assert_parse("<details><summary>Show</summary><div><p>hello world</p></div></details>", "[expand]hello world[/expand]")
  end

  def test_aliased_expand
    assert_parse("<details><summary>hello</summary><div><p>blah blah</p></div></details>", "[expand=hello]blah blah[/expand]")
    assert_parse("<details><summary>hello</summary><div><p>blah blah</p></div></details>", "[expand hello]blah blah[/expand]")
    assert_parse("<details><summary>hello</summary><div><p>blah blah</p></div></details>", "[expand = hello]blah blah[/expand]")
    assert_parse("<details><summary>hello</summary><div><p>blah blah</p></div></details>", "[expand= hello]blah blah[/expand]")
    assert_parse("<details><summary>hello</summary><div><p>blah blah</p></div></details>", "[expand =hello]blah blah[/expand]")
  end

  def test_expand_with_nested_code
    assert_parse("<details><summary>Show</summary><div><pre>hello\n</pre></div></details>", "[expand]\n[code]\nhello\n[/code]\n[/expand]")
  end

  def test_expand_with_nested_list
    assert_parse("<details><summary>Show</summary><div><ul><li>a</li><li>b<br></li></ul></div></details><p>c</p>", "[expand]\n* a\n* b\n[/expand]\nc")
  end

  def test_inline_mode
    assert_equal("hello", parse_inline("hello").strip)
  end

  def test_old_asterisks
    assert_parse("<p>hello *world* neutral</p>", "hello *world* neutral")
  end

  def test_utf8_mentions
    assert_parse('<p><a class="dtext-link dtext-user-mention-link" data-user-name="葉月" href="/users?name=葉月">@葉月</a></p>', "@葉月")
    assert_parse('<p>Hello <a class="dtext-link dtext-user-mention-link" data-user-name="葉月" href="/users?name=葉月">@葉月</a> and <a class="dtext-link dtext-user-mention-link" data-user-name="Alice" href="/users?name=Alice">@Alice</a></p>', "Hello @葉月 and @Alice")
    assert_parse('<p>Should not parse 葉月@葉月</p>', "Should not parse 葉月@葉月")
  end

  def test_mention_boundaries
    assert_parse('<p>「hi <a class="dtext-link dtext-user-mention-link" data-user-name="葉月" href="/users?name=葉月">@葉月</a>」</p>', "「hi @葉月」")
  end

  def test_delimited_mentions
    dtext = '(blah <@evazion>).'
    html = '<p>(blah <a class="dtext-link dtext-user-mention-link" data-user-name="evazion" href="/users?name=evazion">@evazion</a>).</p>'
    assert_parse(html, dtext)
  end

  def test_utf8_links
    assert_parse('<p><a class="dtext-link" href="/posts?tags=approver:葉月">7893</a></p>', '"7893":/posts?tags=approver:葉月')
    assert_parse('<p><a class="dtext-link" href="/posts?tags=approver:葉月">7893</a></p>', '"7893":[/posts?tags=approver:葉月]')
    assert_parse('<p><a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="http://danbooru.donmai.us/posts?tags=approver:葉月">http://danbooru.donmai.us/posts?tags=approver:葉月</a></p>', 'http://danbooru.donmai.us/posts?tags=approver:葉月')
  end

  def test_delimited_links
    dtext = '(blah <https://en.wikipedia.org/wiki/Orange_(fruit)>).'
    html = '<p>(blah <a rel="external nofollow noreferrer" class="dtext-link dtext-external-link" href="https://en.wikipedia.org/wiki/Orange_(fruit)">https://en.wikipedia.org/wiki/Orange_(fruit)</a>).</p>'
    assert_parse(html, dtext)
  end

  def test_nodtext
    assert_parse('<p>[b]not bold[/b]</p><p> <strong>bold</strong></p>', "[nodtext][b]not bold[/b][/nodtext] [b]bold[/b]")
    assert_parse('<p>[b]not bold[/b]</p><p><strong>hello</strong></p>', "[nodtext][b]not bold[/b][/nodtext]\n\n[b]hello[/b]")
    assert_parse('<p> [b]not bold[/b]</p>', " [nodtext][b]not bold[/b][/nodtext]")
  end

  def test_stack_depth_limit
    assert_raises(DText::Error) { parse("* foo\n" * 513) }
  end

  def test_null_bytes
    assert_raises(DText::Error) { parse("foo\0bar") }
  end

  def test_wiki_link_xss
    assert_raises(DText::Error) do
      parse("[[\xFA<script \xFA>alert(42); //\xFA</script \xFA>]]")
    end
  end

  def test_mention_xss
    assert_raises(DText::Error) do
      parse("@user\xF4<b>xss\xFA</b>")
    end
  end

  def test_url_xss
    assert_raises(DText::Error) do
      parse(%("url":/page\xF4">x\xFA<b>xss\xFA</b>))
    end
  end
end
