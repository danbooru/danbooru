require 'cgi'
require 'uri'
require 'stringio'
require 'minitest/autorun'

class ParseError < RuntimeError
end

%%{
  machine dtext;

  name_boundary = ':' | '?';

  newline = '\r\n' | '\r' | '\n';
  
  action mark_a1 {
    a1 = p
  }

  action mark_a2 {
    a2 = p
  }

  action mark_b1 {
    b1 = p
  }

  action mark_b2 {
    b2 = p
  }

  nonquote = ^'"';
  nonbracket = ^']';
  nonpipe = ^'|';
  nonpipebracket = nonpipe & nonbracket;
  noncurly = ^'}';

  mention = '@' >{boundary = false} (graph+) >mark_a1 %mark_a2 :>> name_boundary? @{boundary = true};

  url = 'http' 's'? '://' graph+;
  basic_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':' url >mark_b1 %mark_b2;
  bracketed_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':[' url >mark_b1 %mark_b2 :>> ']';

  basic_wiki_link = '[[' nonpipebracket+ >mark_a1 %mark_a2 ']]';
  aliased_wiki_link = '[[' nonpipebracket+ >mark_a1 %mark_a2 '|' nonbracket+ >mark_b1 %mark_b2 ']]';

  post_link = '{{' noncurly+ >mark_a1 %mark_a2 '}}';

  post_id = 'post #' digit+ >mark_a1 %mark_a2;
  forum_post_id = 'forum #' digit+ >mark_a1 %mark_a2;
  forum_topic_id = 'topic #' digit+ >mark_a1 %mark_a2;
  forum_topic_paged_id = 'topic #' digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;
  comment_id = 'comment #' digit+ >mark_a1 %mark_a2;
  pool_id = 'pool #' digit+ >mark_a1 %mark_a2;
  user_id = 'user #' digit+ >mark_a1 %mark_a2;
  artist_id = 'artist #' digit+ >mark_a1 %mark_a2;
  github_issue_id = 'issue #' digit+ >mark_a1 %mark_a2;
  pixiv_id = 'pixiv #' digit+ >mark_a1 %mark_a2;
  pixiv_paged_id = 'pixiv #' digit+ >mark_a1 %mark_a2 '/p' digit+ >mark_b1 %mark_b2;

  inline := |*
    post_id => {
      id = data[a1...a2]
      append '<a href="/posts/' + id + '">post #' + id + '</a>'
    };

    forum_post_id => {
      id = data[a1...a2]
      append '<a href="/forum_posts/' + id + '">forum #' + id + '</a>'
    };

    forum_topic_id => {
      id = data[a1...a2]
      append '<a href="/forum_topics/' + id + '">topic #' + id + '</a>'
    };

    forum_topic_paged_id => {
      id = data[a1...a2]
      page = data[b1...b2]
      append '<a href="/forum_topics/' + id + '?page=' + page + '">topic #' + id + '/p' + page + '</a>'
    };

    comment_id => {
      id = data[a1...a2]
      append '<a href="/comments/' + id + '">comment #' + id + '</a>'
    };

    pool_id => {
      id = data[a1...a2]
      append '<a href="/pools/' + id + '">pool #' + id + '</a>'
    };

    user_id => {
      id = data[a1...a2]
      append '<a href="/users/' + id + '">user #' + id + '</a>'
    };

    artist_id => {
      id = data[a1...a2]
      append '<a href="/artists/' + id + '">artist #' + id + '</a>'
    };

    github_issue_id => {
      id = data[a1...a2]
      append '<a href="https://github.com/r888888888/danbooru/issues/' + id + '">issue #' + id + '</a>'
    };

    pixiv_id => {
      id = data[a1...a2]
      append '<a href="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=' + id + '">pixiv #' + id + '</a>'
    };

    pixiv_paged_id => {
      id = data[a1...a2]
      page = data[b1...b2]
      append '<a href="http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=' + id + '&page=' + page + '">pixiv #' + id + '/p' + page + '</a>'
    };

    post_link => {
      tags = data[a1...a2]
      append '<a rel="nofollow" href="/posts?tags=' + u(tags) + '">' + h(tags) + '</a>'
    };

    basic_wiki_link => {
      name = data[a1...a2]
      title = name.tr(" ", "_").downcase
      append '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
    };

    aliased_wiki_link => {
      name = data[b1...b2]
      title = data[a1...a2].tr(" ", "_").downcase
      append '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
    };

    basic_textile_link => {
      text = data[a1...a2]
      url = data[b1...b2]
      append '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
    };

    bracketed_textile_link => {
      text = data[a1...a2]
      url = data[b1...b2]
      append '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
    };

    url => {
      url = data[ts...te]
      append '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + url + '</a>'
    };

    '@' graph '@' => {
      # probably a tag. examples include @.@ and @_@
      append data[ts...te]
    };

    mention => {
      name = data[a1...a2]
      if boundary
        marker = data[p]
      else
        marker = ""
      end
      append '<a rel="nofollow" href="/users?name=' + u(name) + '">@' + h(name) + '</a>' + marker
    };

    '[b]' => {
      push_dstack :b
      append '<strong>'
    };

    '[/b]' => {
      raise SyntaxError.new("invalid [/b] tag") unless top_dstack == :b
      pop_dstack
      append "</strong>"
    };

    '[i]' => {
      push_dstack :i
      append '<em>'
    };

    '[/i]' => {
      raise ParseError.new("invalid [/i] tag") unless top_dstack == :i
      pop_dstack
      append "</em>"
    };

    '[s]' => {
      push_dstack :s
      append "<s>"
    };

    '[/s]' => {
      raise ParseError.new("invalid [/s] tag") unless top_dstack == :s
      pop_dstack
      append "</s>"
    };

    '[u]' => {
      push_dstack :u
      append "<u>"
    };

    '[/u]' => {
      raise ParseError.new("invalid [/u] tag") unless top_dstack == :u
      pop_dstack
      append "</u>"
    };

    '[tn]' => {
      push_dstack :tn
      append_block '<p class="tn">'
    };

    '[/tn]' => {
      raise ParseError.new("invalid [/tn] tag") unless top_dstack == :tn
      pop_dstack
      append_block "</p>"
    };

    # these are block level elements that should kick us out of the inline
    # scanner
    '[quote]' => {
      if top_dstack == :p
        append_block "</p>"
        pop_dstack
      end
      p = p - '[quote]'.size;
      fret;
    };

    '[/quote]' => {
      if top_dstack == :p
        append_block "</p>"
        pop_dstack
      end

      raise ParseError.new("invalid [/quote] tag") unless top_dstack == :quote
      pop_dstack
      append_block "</blockquote>"

      fret;
    };

    '[spoiler]' => {
      push_dstack :inline_spoiler
      append '<span class="spoiler">'
    };

    '[/spoiler]' => {
      if top_dstack == :inline_spoiler
        append "</span>"
        pop_dstack
      elsif top_dstack == :block_spoiler
        append_block "</p></div>"
        pop_dstack
        fret;
      else
        raise SyntaxError.new("invalid [/spoiler] tag")
      end
    };

    '[expand]' => {
      close_dstack
      p = p - '[expand]'.size
      fret;
    };

    '[/expand]' => {
      if top_dstack == :block_expand
        append_block '</div></div>'
        pop_dstack
        fret;
      else
        raise SyntaxError.new("invalid [/expand] tag")
      end
    };

    '[nodtext]' => {
      fcall nodtext;
    };

    '[/td]' => {
      if top_dstack != :td
        raise SyntaxError.new("invalid [/td] tag")
      end

      append_block "</td>"
      pop_dstack
      fret;
    };

    # single character entities
    '&' => {
      append "&amp;"
    };

    '<' => {
      append "&lt;"
    };

    '>' => {
      append "&gt;"
    };

    newline{2,} => {
      close_dstack
      fret;
    };

    newline => {
      append_block "<br>"
    };

    # this represents EOF
    '\0' => {
      fhold;
      fret;
    };

    any => {
      append data[p]
    };
  *|;

  code := |*
    '[/code]' => {
      if top_dstack == :block_code
        pop_dstack
        append_block "</pre>"
      else
        raise SyntaxError.new("invalid [/code] tag")
      end
      fret;
    };

    '\0' => {
      fhold;
      fret;
    };

    any => {
      append data[p]
    };
  *|;

  ws = ' ' | '\t';
  header = 'h' [123456] >mark_a1 %mark_a2 '.' ws* print+ >mark_b1 %mark_b2;
  aliased_expand = '[expand=' (nonbracket+ >mark_a1 %mark_a2) ']';

  nodtext := |*
    '[/nodtext]' => {
      if top_dstack == :block_nodtext
        pop_dstack
        append_block "</p>"
      end
      fret;
    };

    '\0' => {
      fhold;
      fret;
    };

    any => {
      append data[p]
    };
  *|;

  table := |*
    '[thead]' => {
      append_block "<thead>"
    };

    '[/thead]' => {
      append_block "</thead>"
    };

    '[tbody]' => {
      append_block "<tbody>"
    };

    '[/tbody]' => {
      append_block "</tbody>"
    };

    '[tr]' => {
      append_block "<tr>"
    };

    '[/tr]' => {
      append_block "</tr>"
    };

    '[td]' => {
      fcall inline;
    };

    '[/table]' => {
      append_block "</table>"
      fret;
    };

    '\0' => {
      raise SyntaxError.new("Invalid table")
    };

    any;
  *|;

  main := |*
    header => {
      if flags[:inline]
        header = "6"
      else
        header = data[a1...a2]
      end

      text = data[b1...b2]
      append_block '<h' + header + '>'
      append h(text)
      append_block '</h' + header + '>'
    };

    '[quote]' => {
      append_block "<blockquote>" unless flags[:inline]
      push_dstack :quote
      fcall inline;
    };

    '[spoiler]' => {
      append_block '<div class="spoiler"><p>'
      push_dstack :block_spoiler
      fcall inline;
    };

    '[code]' => {
      append_block '<pre>'
      push_dstack :block_code
      fcall code;
    };

    '[expand]' => {
      append_block '<div class="expandable"><div class="expandable-header">'
      append_block '<input type="button" value="Show" class="expandable-button"/></div>'
      append_block '<div class="expandable-content">'
      push_dstack :expand
      fcall inline;
    };

    '[nodtext]' => {
      append_block "<p>"
      push_dstack :block_nodtext
      fcall nodtext;
    };

    '[table]' => {
      append_block '<table class="striped">'
      push_dstack :table
      fcall table;
    };

    aliased_expand => {
      msg = data[a1...a2]
      append_block '<div class="expandable"><div class="expandable-header">'
      append_block '<span>' + h(msg) + '</span>'
      append_block '<input type="button" value="Show" class="expandable-button"/></div>'
      append_block '<div class="expandable-content">'
      push_dstack :block_expand
      fcall inline;
    };

    '\0' => {
      close_dstack
    };

    newline;

    any => {
      fhold;

      if dstack.empty?
        append_block "<p>"
        push_dstack :p
      end

      fcall inline;
    };
  *|;
}%%

class DTextRagel
  attr_reader :stack, :dstack, :data, :eof, :flags

  def initialize(string, flags = {})
    @output = StringIO.new
    @stack = []
    @dstack = []
    @data = string + "\0"
    @eof = @data.size
    @flags = flags

    %% write data;
  end

  def h(x)
    CGI.escapeHTML(x)
  end

  def u(x)
    CGI.escape(x)
  end

  def append(string)
    @output << string
  end

  def append_block(string)
    if @flags[:inline]
      @output << " "
    else
      @output << string
    end
  end

  def push_dstack(obj)
    @dstack << obj
  end

  def pop_dstack
    @dstack.pop
  end

  def top_dstack
    @dstack[-1]
  end

  def close_dstack
    while obj = pop_dstack
      case obj
      when :p
        append_block "</p>"

      when :inline_spoiler
        append "</span>"

      when :block_spoiler
        append_block "</p></div>"

      when :block_quote
        append_block "</pre>"

      when :block_expand
        append_block "</div></div>"

      when :block_nodtext
        append_block "</p>"

      when :block_code
        append_block "</pre>"

      when :quote
        append_block "</blockquote>"

      else
        raise SyntaxError.new("Invalid element #{obj}")
      end
    end
  end

  def parse
    %% write init;
    %% write exec;

    @output.string
  end
end

class DTextRagelTest < Minitest::Test
  def p(s)
    DTextRagel.new(s).parse
  end

  def pi(s)
    DTextRagel.new(s, :inline => true).parse
  end

  def assert_parse(expected, input)
    assert_equal(expected, p(input))
  end

  def test_mentions
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"/users?name=he%27llo\">@he&#39;llo</a> blah</p>", "alpha @he'llo blah")
    assert_parse("<p>@.@ @_@</p>", "@.@ @_@")
  end

  def test_mention_with_boundary
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"/users?name=he%27llo\">@he&#39;llo</a>: blah</p>", "alpha @he'llo: blah")
  end

  def test_url_linking
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"http://google.com/blah/image.gif?zap=blah&hell=mary\">http://google.com/blah/image.gif?zap=blah&hell=mary</a> beta</p>", "alpha http://google.com/blah/image.gif?zap=blah&hell=mary beta")
  end

  def test_textile_linking
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"http://google.com?zap=blah&hell=mary\">blah</a> beta</p>", 'alpha "blah":http://google.com?zap=blah&hell=mary beta')
  end

  def test_textile_linking_bracketed
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"http://google.com\">blah</a> beta</p>", 'alpha "blah":[http://google.com] beta')
  end

  def test_wiki_linking
    assert_parse("<p>alpha <a href=\"/wiki_pages/show_or_new?title=wiki_page_title\">wiki page title</a> beta</p>", 'alpha [[wiki page title]] beta')
  end

  def test_wiki_linking_aliased
    assert_parse("<p>alpha <a href=\"/wiki_pages/show_or_new?title=wiki_page_title\">shown text</a> beta</p>", 'alpha [[wiki page title|shown text]] beta')
  end

  def test_spoiler_wiki_linking
    assert_parse("<p>alpha <a href=\"/wiki_pages/show_or_new?title=spoiler\">spoiler</a> beta</p>", 'alpha [[spoiler]] beta')
  end

  def test_search_linking
    assert_parse("<p>alpha <a rel=\"nofollow\" href=\"/posts?tags=blah+pah\">blah pah</a> beta</p>", 'alpha {{blah pah}} beta')
  end

  def test_post_id_linking
    assert_parse("<p>alpha <a href=\"/posts/1234\">post #1234</a> beta</p>", 'alpha post #1234 beta')
  end

  def test_forum_post_id_linking
    assert_parse("<p>alpha <a href=\"/forum_posts/1234\">forum #1234</a> beta</p>", 'alpha forum #1234 beta')
  end

  def test_forum_topic_id_linking
    assert_parse("<p>alpha <a href=\"/forum_topics/1234\">topic #1234</a> beta</p>", 'alpha topic #1234 beta')
  end

  def test_forum_topic_id_paginated_linking
    assert_parse("<p>alpha <a href=\"/forum_topics/1234?page=5\">topic #1234/p5</a> beta</p>", 'alpha topic #1234/p5 beta')
  end

  def test_headers
    assert_parse("<h1>blah blah</h1><p>hey</p>", "h1. blah blah\nhey")
  end

  def test_quotes
    assert_parse("<blockquote>hello andy</blockquote><p>blah<br></p><blockquote>bad andy</blockquote>", "[quote]hello andy[/quote]\nblah\n[quote]bad andy[/quote]")
  end

  def test_nested_quotes
    assert_parse("<blockquote>hello <blockquote>blah</blockquote></blockquote>", "[quote]hello [quote]blah[/quote][/quote]")
  end

  def test_block_spoilers
    assert_parse("<div class=\"spoiler\"><p>hello world</p></div>", "[spoiler]hello world[/spoiler]")
  end

  def test_inline_spoilers
    assert_parse("<p>inline text <span class=\"spoiler\">inline spoilers</span> blah</p>", "inline text [spoiler]inline spoilers[/spoiler] blah")
    assert_parse("<p> <span class=\"spoiler\">inline spoilers</span> blah</p>", " [spoiler]inline spoilers[/spoiler] blah")
  end

  def test_nested_spoilers
    assert_parse("<div class=\"spoiler\"><p>this is <span class=\"spoiler\">a nested</span> spoiler</p></div>", "[spoiler]this is [spoiler]a nested[/spoiler] spoiler[/spoiler]")
  end

  def test_unclosed_spoilers
    assert_parse("<div class=\"spoiler\"><p>hello world</p></div>", "[spoiler]hello world")
    assert_parse("<div class=\"spoiler\"><p>hello world<br>new text</p></div>", "[spoiler]hello world\nnew text")
  end

  def test_paragraph
    assert_parse("<p>abc</p>", "abc")
  end

  def test_newlines
    assert_parse("<p>a<br>b<br>c</p>", "a\nb\nc")
    assert_parse("<p>a</p><p>b</p>", "a\n\nb")
  end

  def test_entities
    assert_parse("<p>&lt;3</p>", "<3")
  end

  def test_code
    assert_parse("<pre>for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);</pre>", "[code]for (i=0; i<5; ++i) {\n  printf(1);\n}\n\nexit(1);[/code]")
  end

  def test_nodtext
    assert_parse("<p>[spoiler]hello\nworld[/spoiler]</p>", "[nodtext][spoiler]hello\nworld[/spoiler][/nodtext]")
    assert_parse("<p>alpha [spoiler]ayyyy[/spoiler] beta</p>", "alpha [nodtext][spoiler]ayyyy[/spoiler][/nodtext] beta")
  end

  def test_expand
    assert_parse("<div class=\"expandable\"><div class=\"expandable-header\"><span>blah blah</span><input type=\"button\" value=\"Show\" class=\"expandable-button\"/></div><div class=\"expandable-content\">hello world</div></div>", "[expand=blah blah]hello world[/expand]")
  end

  def test_complex_links_1
    assert_parse("<p><a href=\"/wiki_pages/show_or_new?title=1\">2 3</a> | <a href=\"/wiki_pages/show_or_new?title=4\">5 6</a></p>", "[[1|2 3]] | [[4|5 6]]")
    assert_parse("<p>Tags <strong>(<a href=\"/wiki_pages/show_or_new?title=howto%3Atag\">Tagging Guidelines</a> | <a href=\"/wiki_pages/show_or_new?title=howto%3Atag_checklist\">Tag Checklist</a> | <a href=\"/wiki_pages/show_or_new?title=tag_groups\">Tag Groups</a>)</strong></p>", "Tags [b]([[howto:tag|Tagging Guidelines]] | [[howto:tag_checklist|Tag Checklist]] | [[Tag Groups]])[/b]")
  end

  def test_inline_flag
    assert_equal("alpha <span class=\"spoiler\">hello</span> jesus", pi("alpha [spoiler]hello[/spoiler]\n\n[quote]jesus[/quote]").strip)
  end
end

