require 'cgi'
require 'uri'

class DText
  def self.u(string)
    CGI.escape(string)
  end
  
  def self.h(string)
    CGI.escapeHTML(string)
  end
  
  def self.parse_inline(str, options = {})
    str.gsub!(/&/, "&amp;")
    str.gsub!(/</, "&lt;")
    str.gsub!(/>/, "&gt;")
    str.gsub!(/\n/m, "<br>")
    str.gsub!(/\[b\](.+?)\[\/b\]/i, '<strong>\1</strong>')
    str.gsub!(/\[i\](.+?)\[\/i\]/i, '<em>\1</em>')
    str.gsub!(/(?<![=\]])(https?:\/\/\S+)/m) do |link|
      if link =~ /([;,.!?\)\]])$/
        stop = $1
        link.chop!
        text = link
      else
        stop = ""
        text = link
      end

      link.gsub!(/"/, '&quot;')
      '<a href="' + link + '">' + text + '</a>' + stop
    end
    str.gsub!(/\[url\](http.+?)\[\/url\]/i) do
      %{<a href="#{$1}">#{$1}</a>}
    end
    str.gsub!(/\[url=(http.+?)\](.+?)\[\/url\]/m) do
      %{<a href="#{$1}">#{$2}</a>}
    end
    str = parse_aliased_wiki_links(str)
    str = parse_wiki_links(str)
    str = parse_post_links(str)
    str = parse_id_links(str)
    str
  end
  
  def self.parse_aliased_wiki_links(str)
    str.gsub(/\[\[(.+?)\|(.+?)\]\]/m) do
      text = CGI.unescapeHTML($1)
      title = CGI.unescapeHTML($2)
      wiki_page = WikiPage.find_title_and_id(title)
      
      if wiki_page
        %{<a href="/wiki_pages/#{wiki_page.id}">#{h(text)}</a>}
      else
        %{<a href="/wiki_pages/new?title=#{u(title)}">#{h(text)}</url>}
      end
    end
  end
  
  def self.parse_wiki_links(str)
    str.gsub(/\[\[(.+?)\]\]/) do
      title = CGI.unescapeHTML($1)
      wiki_page = WikiPage.find_title_and_id(title)
      
      if wiki_page
        %{<a href="/wiki_pages/#{wiki_page.id}">#{h(title)}</a>}
      else
        %{<a href="/wiki_pages/new?wiki_page[title]=#{u(title)}">#{h(title)}</a>}
      end
    end
  end
  
  def self.parse_post_links(str)
    str.gsub(/\{\{(.+?)\}\}/) do
      tags = CGI.unescapeHTML($1)
      %{<a href="/posts?tags=#{u(tags)}">#{h(tags)}</a>}
    end
  end
  
  def self.parse_id_links(str)
    str = str.gsub(/\bpost #(\d+)/i, %{<a href="/posts/\\1">post #\\1</a>})
    str = str.gsub(/\bforum #(\d+)/i, %{<a href="/forum_posts/\\1">forum #\\1</a>})
    str = str.gsub(/\bcomment #(\d+)/i, %{<a href="/comments/\\1">comment #\\1</a>})
    str = str.gsub(/\bpool #(\d+)/i, %{<a href="/pools/\\1">pool #\\1</a>})
  end
  
  def self.parse_list(str, options = {})
    html = ""
    layout = []
    nest = 0

    str.split(/\n/).each do |line|
      if line =~ /^\s*(\*+) (.+)/
        nest = $1.size
        content = parse_inline($2)
      else
        content = parse_inline(line)
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

      html += "<li>#{content}</li>"
    end

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
      str.gsub!(/\s*\[quote\]\s*/m, "\n\n[quote]\n\n")
      str.gsub!(/\s*\[\/quote\]\s*/m, "\n\n[/quote]\n\n")
      str.gsub!(/\s*\[spoilers?\](?!\])\s*/m, "\n\n[spoiler]\n\n")
      str.gsub!(/\s*\[\/spoilers?\]\s*/m, "\n\n[/spoiler]\n\n")
    end
    
    str.gsub!(/(?:\r?\n){3,}/, "\n\n")
    str.strip!
    blocks = str.split(/(?:\r?\n){2}/)
    stack = []
    
    html = blocks.map do |block|
      case block
      when /^(h[1-6])\.\s*(.+)$/
        tag = $1
        content = $2      
          
        if options[:inline]
          "<h6>" + parse_inline(content, options) + "</h6>"
        else
          "<#{tag}>" + parse_inline(content, options) + "</#{tag}>"
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

      when /\[spoilers?\](?!\])/
        stack << "div"
        '<div class="spoiler">'
        
      when /\[\/spoilers?\]/
        if stack.last == "div"
          stack.pop
          '</div>'
        end

      else
        '<p>' + parse_inline(block) + "</p>"
      end
    end
    
    stack.reverse.each do |tag|
      if tag == "blockquote"
        html << "</blockquote>"
      elsif tag == "div"
        html << "</div>"
      end
    end

    sanitize(html.join("")).html_safe
  end
  
  def self.sanitize(text)
    Sanitize.clean(
      text,
      :elements => %w(tn h1 h2 h3 h4 h5 h6 a span div blockquote br p ul li ol em strong small big b i font),
      :attributes => {
        "a" => %w(href title style),
        "span" => %w(class style),
        "div" => %w(class style),
        "p" => %w(class style),
        "font" => %w(color size style)
      },
      :protocols => {
        "a" => {
          "href" => ["http", "https", :relative]
        }
      }
    )
  end
end

