require 'cgi'
require 'uri'
require 'stringio'

%%{
  machine dtext;

  name_boundary = ':' | ';' | ',' | '.' | '!' | '?' | ')' | ']' | '<' | '>';

  newline = '\r\n' | '\r' | '\n';
  
  mention = '@' . graph+;

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

  url = 'http' 's'? '://' graph+;
  basic_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':' url >mark_b1 @mark_b2;
  bracketed_textile_link = '"' nonquote+ >mark_a1 '"' >mark_a2 ':[' url >mark_b1 @mark_b2 :>> ']';

  basic_wiki_link = '[[' nonpipebracket+ >mark_a1 @mark_a2 ']]';
  aliased_wiki_link = '[[' nonpipebracket+ >mark_a1 @mark_a2 '|' nonbracket+ >mark_b1 @mark_b2 ']]';

  post_link = '{{' noncurly+ >mark_a1 @mark_a2 '}}';

  post_id = 'post #' digit+ >mark_a1 @mark_a2;
  forum_post_id = 'forum #' digit+ >mark_a1 @mark_a2;
  forum_topic_id = 'topic #' digit+ >mark_a1 @mark_a2;
  forum_topic_paged_id = 'topic #' digit+ >mark_a1 @mark_a2 '/p' digit+ >mark_b1 @mark_b2;
  comment_id = 'comment #' digit+ >mark_a1 @mark_a2;
  pool_id = 'pool #' digit+ >mark_a1 @mark_a2;
  user_id = 'user #' digit+ >mark_a1 @mark_a2;
  artist_id = 'artist #' digit+ >mark_a1 @mark_a2;
  github_issue_id = 'issue #' digit+ >mark_a1 @mark_a2;
  pixiv_id = 'pixiv #' digit+ >mark_a1 @mark_a2;
  pixiv_paged_id = 'pixiv #' digit+ >mark_a1 @mark_a2 '/p' digit+ >mark_b1 @mark_b2;

  inline := |*
    post_id => {
      id = data[a1..a2]
      output << '<a href="/posts/' + id + '">post #' + id + '</a>'
    };

    forum_post_id => {
      id = data[a1..a2]
      output << '<a href="/forum_posts/' + id + '">forum #' + id + '</a>'
    };

    forum_topic_id => {
      id = data[a1..a2]
      output << '<a href="/forum_topics/' + id + '">topic #' + id + '</a>'
    };

    forum_topic_paged_id => {
      id = data[a1..a2]
      page = data[b1..b2]
      output << '<a href="/forum_topics/' + id + '?page=' + page + '">topic #' + id + '/p' + page + '</a>'
    };

    comment_id => {
      id = data[a1..a2]
      output << '<a href="/comments/' + id + '">comment #' + id + '</a>'
    };

    pool_id => {
      id = data[a1..a2]
      output << '<a href="/pools/' + id + '">pool #' + id + '</a>'
    };

    user_id => {
      id = data[a1..a2]
      output << '<a href="/users/' + id + '">user #' + id + '</a>'
    };

    artist_id => {
      id = data[a1..a2]
      output << '<a href="/artists/' + id + '">artist #' + id + '</a>'
    };

    github_issue_id => {
      id = data[a1..a2]
      output << '<a href="https://github.com/r888888888/danbooru/issues/' + id + '">issue #' + id + '</a>'
    };

    pixiv_id => {
      id = data[a1..a2]
      output << '<a href="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=' + id + '">pixiv #' + id + '</a>'
    };

    pixiv_paged_id => {
      id = data[a1..a2]
      page = data[b1..b2]
      output << '<a href="http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=' + id + '&page=' + page + '">pixiv #' + id + '/p' + page + '</a>'
    };

    post_link => {
      tags = data[a1..a2]
      output << '<a rel="nofollow" href="/posts?tags=' + u(tags) + '">' + h(tags) + '</a>'
    };

    basic_wiki_link => {
      name = data[a1..a2]
      title = name.tr(" ", "_").downcase
      output << '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
    };

    aliased_wiki_link => {
      name = data[b1..b2]
      title = data[a1..a2].tr(" ", "_").downcase
      output << '<a href="/wiki_pages/show_or_new?title=' + u(title) + '">' + h(name) + '</a>'
    };

    basic_textile_link => {
      text = data[a1..a2]
      url = data[b1..b2]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
    };

    bracketed_textile_link => {
      text = data[a1..a2]
      url = data[b1..b2]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + text + '</a>'
    };

    url => {
      url = data[ts...te]
      output << '<a rel="nofollow" href="' + URI.parse(url).to_s + '">' + url + '</a>'
    };

    mention name_boundary => {
      name = data[ts+1...te-1]
      output << '<a rel="nofollow" href="/users?name=' + u(name) + '">@' + h(name) + '</a>' + data[p]
    };

    mention => {
      name = data[ts+1...te]
      output << '<a rel="nofollow" href="/users?name=' + u(name) + '">@' + h(name) + '</a>'
    };

    '[b]' => {
      dstack << :b
      output << '<strong>'
    };

    '[/b]' => {
      raise SyntaxError.new("invalid [/b] tag") unless dstack[-1] == :b
      dstack.pop
      output << "</strong>"
    };

    '[i]' => {
      dstack << :i
      output << '<em>'
    };

    '[/i]' => {
      raise ParseError.new("invalid [/i] tag") unless dstack[-1] == :i
      dstack.pop
      output << "</em>"
    };

    '[s]' => {
      dstack << :s
      output << "<s>"
    };

    '[/s]' => {
      raise ParseError.new("invalid [/s] tag") unless dstack[-1] == :s
      dstack.pop
      output << "</s>"
    };

    '[u]' => {
      dstack << :u
      output << "<u>"
    };

    '[/u]' => {
      raise ParseError.new("invalid [/u] tag") unless dstack[-1] == :u
      dstack.pop
      output << "</u>"
    };

    '[tn]' => {
      dstack << :tn
      output << '<p class="tn">'
    };

    '[/tn]' => {
      raise ParseError.new("invalid [/tn] tag") unless dstack[-1] == :tn
      dstack.pop
      output << "</p>"
    };

    '[/quote]' => {
      raise ParseError.new("invalid [/quote] tag") unless dstack[-1] == :quote
      dstack.pop
      output << "</blockquote>"
      fret;
    };

    '[spoiler]' => {
      dstack << :inline_spoiler
      output << '<span class="spoiler">'
    };

    '[/spoiler]' => {
      if dstack[-1] == :inline_spoiler
        output << "</span>"
        dstack.pop
      elsif dstack[-1] == :block_spoiler
        output << "</div>"
        dstack.pop
        fret;
      else
        raise SyntaxError.new("invalid [/spoiler] tag")
      end
    };

    '[/expand]' => {
      if dstack[-1] == :expand
        output << '</div></div>'
        dstack.pop
        fret;
      else
        raise SyntaxError.new("invalid [/expand] tag")
      end
    };

    '&' => {
      output << "&amp;"
    };

    '<' => {
      output << "&lt;"
    };

    '>' => {
      output << "&gt;"
    };

    newline{2,} {
      output << close_stack(output, dstack)
      fret;
    };

    newline => {
      output << "<br>"
    };

    '\0' => {
      fhold;
      fret;
    };

    any => {
      output << data[p]
    };
  *|;

  code := |*
    '[/code]' => {
      if dstack[-1] == :block_code
        dstack.pop
        output << "</pre>"
      else
        raise SyntaxError.new("invalid [/code] tag")
      end
      fret;
    };

    '\0' => {
      fhold;
      fret;
    };

    '[' => {
      output << "["
    };

    (^'[')+ => {
      output << data[ts...te]
    };
  *|;

  ws = ' ' | '\t';
  header = 'h' [123456] >mark_a1 @mark_a2 '.' ws* print+ >mark_b1 @mark_b2;
  aliased_expand = '[expand=' (nonbracket+ >mark_a1 @mark_a2) ']';

  main := |*
    header => {
      if flags[:inline]
        header = "6"
      else
        header = data[a1..a2]
      end

      text = data[b1..b2]
      output << '<h' + header + '>' + h(text) + '</h' + header + '>'
    };

    '[quote]' => {
      output << "<blockquote>"
      dstack << :quote
      fcall inline;
    };

    '[spoiler]' => {
      output << '<div class="spoiler">'
      dstack << :block_spoiler
      fcall inline;
    };

    '[code]' => {
      output << '<pre>'
      dstack << :block_code
      fcall code;
    };

    '[expand]' => {
      output << '<div class="expandable"><div class="expandable-header">'
      output << '<input type="button" value="Show" class="expandable-button"/></div>'
      output << '<div class="expandable-content">'
      dstack << :expand
      fcall inline;
    };

    aliased_expand => {
      msg = data[a1..a2]
      output <<'<div class="expandable"><div class="expandable-header">'
      output << '<span>' + h(msg) + '</span>'
      output << '<input type="button" value="Show" class="expandable-button"/></div>'
      output << '<div class="expandable-content">'
      dstack << :expand
      fcall inline;
    };

    '\0' => {
      close_stack(output, dstack)
    };

    newline;

    any => {
      fhold;

      if dstack.empty?
        output << "<p>"
        dstack << :p
      end

      fcall inline;
    };
  *|;
}%%

class DTextRagel
  %% write data;

  def self.h(x)
    CGI.escapeHTML(x)
  end

  def self.u(x)
    CGI.escape(x)
  end

  def self.close_stack(output, stack)
    while obj = stack.pop
      case obj
      when :p
        output << "</p>"

      when :inline_spoiler
        output << "</span>"

      when :block_spoiler
        output << "</div>"

      when :block_quote
        output << "</pre>"

      else
        raise SyntaxError.new("Invalid element #{obj}")
      end
    end
  end

  def self.parse(s)
    stack = []
    dstack = []
    output = StringIO.new
    data = s + "\0"
    eof = data.size
    flags = {}

    %% write init;
    %% write exec;

    output.string
  end
end
