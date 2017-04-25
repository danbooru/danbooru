require 'cgi'
require 'uri'

class DText
  MENTION_REGEXP = /(?<=^| )@\S+/
  
  def self.u(string)
    CGI.escape(string)
  end

  def self.h(string)
    CGI.escapeHTML(string)
  end

  def self.quote(message, creator_name)
    stripped_body = DText.strip_blocks(message, "quote")
    "[quote]\n#{creator_name} said:\n\n#{stripped_body}\n[/quote]\n\n"
  end

  def self.strip_blocks(string, tag)
    n = 0
    stripped = ""
    string = string.dup

    string.gsub!(/\s*\[#{tag}\](?!\])\s*/mi, "\n\n[#{tag}]\n\n")
    string.gsub!(/\s*\[\/#{tag}\]\s*/mi, "\n\n[/#{tag}]\n\n")
    string.gsub!(/(?:\r?\n){3,}/, "\n\n")
    string.strip!

    string.split(/\n{2}/).each do |block|
      case block
      when "[#{tag}]"
        n += 1

      when "[/#{tag}]"
        n -= 1

      else
        if n == 0
          stripped << "#{block}\n\n"
        end
      end
    end

    stripped.strip
  end

  def self.parse_inline(str, options = {})
    str.gsub!(/&/, "&amp;")
    str.gsub!(/</, "&lt;")
    str.gsub!(/>/, "&gt;")
    str.gsub!(/\n/m, "<br>") unless options[:ignore_newlines]
    str.gsub!(/\[b\](.+?)\[\/b\]/i, '<strong>\1</strong>')
    str.gsub!(/\[i\](.+?)\[\/i\]/i, '<em>\1</em>')
    str.gsub!(/\[s\](.+?)\[\/s\]/i, '<s>\1</s>')
    str.gsub!(/\[u\](.+?)\[\/u\]/i, '<u>\1</u>')
    str.gsub!(/\[tn\](.+?)\[\/tn\]/i, '<p class="tn">\1</p>')

    str = parse_mentions(str, options)
    str = parse_links(str)
    str = parse_aliased_wiki_links(str)
    str = parse_wiki_links(str)
    str = parse_post_links(str)
    str = parse_id_links(str)
    str
  end

  def self.parse_mentions(str, options = {})
    return if options[:disable_mentions]

    str.gsub!(MENTION_REGEXP) do |name| 
      next name unless name =~ /[a-z0-9]/i

      if name =~ /([:;,.!?\)\]<>])$/
        name.chop!
        ch = $1
      else
        ch = ""
      end

      '<a href="/users?name=' + u(CGI.unescapeHTML(name[1..-1])) + '">' + name + '</a>' + ch
    end
    str
  end

  def self.parse_table_elements(str)
    str = parse_inline(str, :ignore_newlines => true)
    str.gsub!(/\[(\/?(?:tr|td|th|thead|tbody))\]/, '<\1>')
    str
  end

  def self.parse_links(str)
    str.gsub(/("[^"]+":(https?:\/\/|\/)[^\s\r\n<>]+|https?:\/\/[^\s\r\n<>]+|"[^"]+":\[(https?:\/\/|\/)[^\s\r\n<>\]]+\])+/) do |url|
      ch = ""

      if url =~ /^"([^"]+)":\[(.+)\]$/
        text = $1
        url = $2
      else
        if url =~ /^"([^"]+)":(.+)$/
          text = $1
          url = $2
        else
          text = url
        end

        if url =~ /([;,.!?\)\]<>])$/
          url.chop!
          ch = $1
        end
      end

      '<a href="' + url + '">' + text + '</a>' + ch
    end
  end

  def self.parse_aliased_wiki_links(str)
    str.gsub(/\[\[([^\|\]]+)\|([^\]]+)\]\]/m) do
      text = CGI.unescapeHTML($2)
      title = CGI.unescapeHTML($1).tr(" ", "_").downcase
      %{<a href="/wiki_pages/show_or_new?title=#{u(title)}">#{h(text)}</a>}
    end
  end

  def self.parse_wiki_links(str)
    str.gsub(/\[\[([^\]]+)\]\]/) do
      text = CGI.unescapeHTML($1)
      title = text.tr(" ", "_").downcase
      %{<a href="/wiki_pages/show_or_new?title=#{u(title)}">#{h(text)}</a>}
    end
  end

  def self.parse_post_links(str)
    str.gsub(/\{\{([^\}]+)\}\}/) do
      tags = CGI.unescapeHTML($1)
      %{<a rel="nofollow" href="/posts?tags=#{u(tags)}">#{h(tags)}</a>}
    end
  end

  def self.parse_id_links(str)
    str = str.gsub(/\bpost #(\d+)/i, %{<a href="/posts/\\1">post #\\1</a>})
    str = str.gsub(/\bforum #(\d+)/i, %{<a href="/forum_posts/\\1">forum #\\1</a>})
    str = str.gsub(/\btopic #(\d+)(?!\/p\d|\d)/i, %{<a href="/forum_topics/\\1">topic #\\1</a>})
    str = str.gsub(/\btopic #(\d+)\/p(\d+)/i, %{<a href="/forum_topics/\\1?page=\\2">topic #\\1/p\\2</a>})
    str = str.gsub(/\bcomment #(\d+)/i, %{<a href="/comments/\\1">comment #\\1</a>})
    str = str.gsub(/\bpool #(\d+)/i, %{<a href="/pools/\\1">pool #\\1</a>})
    str = str.gsub(/\buser #(\d+)/i, %{<a href="/users/\\1">user #\\1</a>})
    str = str.gsub(/\bartist #(\d+)/i, %{<a href="/artists/\\1">artist #\\1</a>})
    str = str.gsub(/\bissue #(\d+)/i, %{<a href="https://github.com/r888888888/danbooru/issues/\\1">issue #\\1</a>})
    str = str.gsub(/\bpixiv #(\d+)(?!\/p\d|\d)/i, %{<a href="http://www.pixiv.net/member_illust.php?mode=medium&illust_id=\\1">pixiv #\\1</a>})
    str = str.gsub(/\bpixiv #(\d+)\/p(\d+)/i, %{<a href="http://www.pixiv.net/member_illust.php?mode=manga_big&illust_id=\\1&page=\\2">pixiv #\\1/p\\2</a>})
  end

  def self.parse_list(str, options = {})
    html = ""
    current_item = ""
    layout = []
    nest = 0

    str.split(/\n/).each do |line|
      if line =~ /^\s*(\*+) (.+)/
        if nest > 0
          html += "<li>#{current_item}</li>"
        elsif not current_item.strip.empty?
          html += "<p>#{current_item}</p>"
        end

        nest = $1.size
        current_item = parse_inline($2)
      else
        current_item += parse_inline(line)
      end

      if nest > layout.size
        html += "<ul>"
        layout << "ul"
      end

      while nest < layout.size
        elist = layout.pop
        if elist
          html += "</#{elist}>"
        end
      end
    end

    html += "<li>#{current_item}</li>"

    while layout.any?
      elist = layout.pop
      html += "</#{elist}>"
    end

    html
  end

  def self.parse(str, options = {})
    return "" if str.blank?

    # Make sure quote tags are surrounded by newlines

    unless options[:inline]
      str.gsub!(/\s*\[quote\](?!\])\s*/m, "\n\n[quote]\n\n")
      str.gsub!(/\s*\[\/quote\]\s*/m, "\n\n[/quote]\n\n")
      str.gsub!(/\s*\[code\](?!\])/m, "\n\n[code]\n\n")
      str.gsub!(/\[\/code\]\s*/m, "\n\n[/code]\n\n")
      str.gsub!(/\s*\[spoilers?\](?!\])\s*/m, "\n\n[spoiler]\n\n")
      str.gsub!(/\s*\[\/spoilers?\]\s*/m, "\n\n[/spoiler]\n\n")
      str.gsub!(/^(h[1-6](\#[A-z][_A-z0-9-]+)?\.\s*.+)$/, "\n\n\\1\n\n")
      str.gsub!(/\s*\[expand(\=[^\]]*)?\](?!\])\s*/m, "\n\n[expand\\1]\n\n")
      str.gsub!(/\s*\[\/expand\]\s*/m, "\n\n[/expand]\n\n")
      str.gsub!(/\s*\[table\](?!\])\s*/m, "\n\n[table]\n\n")
      str.gsub!(/\s*\[\/table\]\s*/m, "\n\n[/table]\n\n")
    end

    str.gsub!(/(?:\r?\n){3,}/, "\n\n")
    str.strip!
    blocks = str.split(/(?:\r?\n){2}/)
    stack = []
    flags = {}

    html = blocks.map do |block|
      case block
      when /\A(h[1-6])\.\s*(.+)\Z/
        tag = $1
        content = $2

        if options[:inline]
          "<h6>" + parse_inline(content, options) + "</h6>"
        else
          "<#{tag}>" + parse_inline(content, options) + "</#{tag}>"
        end
      when /\A(h[1-6])\#([A-z][_A-z0-9-]+)\.\s*(.+)\Z/
        tag = $1
        header_id = $2
        content = $3
        
        if options[:inline]
          "<h6 id=\"dtext-#{header_id}\">" + parse_inline(content, options) + "</h6>"
        else
          "<#{tag} id=\"dtext-#{header_id}\">" + parse_inline(content, options) + "</#{tag}>"
        end
      when /^\s*\*+ /
        parse_list(block, options)

      when "[quote]"
        if options[:inline]
          ""
        else
          stack << "blockquote"
          "<blockquote>"
        end

      when "[/quote]"
        if options[:inline]
          ""
        elsif stack.last == "blockquote"
          stack.pop
          '</blockquote>'
        else
          ""
        end

      when "[spoiler]"
        stack << "spoiler"
        '<div class="spoiler">'

      when "[/spoiler]"
        if stack.last == "spoiler"
          stack.pop
          "</div>"
        else
          ""
        end

      when "[table]"
        stack << "table"
        flags[:table] = true
        '<table class="striped">'

      when "[/table]"
        if stack.last == "table"
          stack.pop
          flags[:table] = false
          "</table>"
        else
          ""
        end

      when /\[code\](?!\])/
        flags[:code] = true
        stack << "pre"
        '<pre>'

      when /\[\/code\](?!\])/
        flags[:code] = false
        if stack.last == "pre"
          stack.pop
          "</pre>"
        else
          ""
        end

      when /\[expand(?:\=([^\]]*))?\](?!\])/
        stack << "expandable"
        expand_html = '<div class="expandable"><div class="expandable-header">'
        expand_html << "<span>#{h($1)}</span>" if $1.present?
        expand_html << '<input type="button" value="Show" class="expandable-button"/></div>'
        expand_html << '<div class="expandable-content">'
        expand_html

      when /\[\/expand\](?!\])/
        if stack.last == "expandable"
          stack.pop
          '</div></div>'
        end

      else
        if flags[:code]
          CGI.escape_html(block) + "\n\n"
        elsif flags[:table]
          parse_table_elements(block)
        else
          '<p>' + parse_inline(block) + '</p>'
        end
      end
    end

    stack.reverse.each do |tag|
      if tag == "blockquote"
        html << "</blockquote>"
      elsif tag == "div"
        html << "</div>"
      elsif tag == "pre"
        html << "</pre>"
      elsif tag == "spoiler"
        html << "</div>"
      elsif tag == "expandable"
        html << "</div></div>"
      elsif tag == "table"
        html << "</table>"
      end
    end

    html.join("").html_safe
  end

  def self.parse_strip(s)
    strip(s)
  end

  def self.strip(s)
    return "" if s.blank?

    s.gsub!(/[\r\n]+/m, " ")
    s.gsub!(/\[\/?(?:b|i|s|u|tn|tr|td|th|thead|tbody|quote|code|spoilers|spoiler|expand|table)\]/, "")
    s.gsub!(/\[\[([^\|\]]+)\|([^\]]+)\]\]/m, '\2')
    s.gsub!(/\[\[([^\]]+)\]\]/, '\1')
    s.gsub!(/\{\{([^\}]+)\}\}/, '\1')
    s.gsub!(/("[^"]+":(https?:\/\/|\/)[^\s\r\n<>]+|https?:\/\/[^\s\r\n<>]+|"[^"]+":\[(https?:\/\/|\/)[^\s\r\n<>\]]+\])+/) do |url|
      if url =~ /^"([^"]+)":\[(.+)\]$/
        $1
      elsif url =~ /^"([^"]+)":(.+)$/
        $1
      else
        url
      end
    end
    s
  end

  def self.sanitize(text)
    text.gsub!(/<( |-|3|:|>|\Z)/, "&lt;\\1")

    Sanitize.clean(
      text,
      :elements => %w(code center tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em strong small big b i font u s pre ruby rb rt rp),
      :attributes => {
        "a" => %w(href title style),
        "span" => %w(class style),
        "div" => %w(class style align),
        "p" => %w(class style align),
        "font" => %w(color size style)
      },
      :protocols => {
        "a" => {
          "href" => ["http", "https", :relative]
        }
      },
      :css => Sanitize::Config::RELAXED[:css].merge({
        :protocols => []
      })
    )
  end

  # extract the first paragraph `needle` occurs in.
  def self.excerpt(dtext, needle)
    dtext = dtext.gsub(/\r\n|\r|\n/, "\n")
    excerpt = ActionController::Base.helpers.excerpt(dtext, needle, separator: "\n\n", radius: 1, omission: "")
    excerpt
  end
end

