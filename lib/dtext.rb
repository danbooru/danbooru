#!/usr/bin/env ruby

require 'cgi'

module DText
  def parse_inline(str, options = {})
    str = str.gsub(/&/, "&amp;")
    str.gsub!(/</, "&lt;")
    str.gsub!(/>/, "&gt;")
    str.gsub!(/\[\[.+?\]\]/m) do |tag|
      tag = tag[2..-3]
      if tag =~ /^(.+?)\|(.+)$/
        tag = $1
        name = $2
        '<a href="/wiki/show?title=' + CGI.escape(CGI.unescapeHTML(tag.tr(" ", "_").downcase)) + '">' + name + '</a>'
      else
        '<a href="/wiki/show?title=' + CGI.escape(CGI.unescapeHTML(tag.tr(" ", "_").downcase)) + '">' + tag + '</a>'
      end
    end
    str.gsub!(/\{\{.+?\}\}/m) do |tag|
      tag = tag[2..-3]
      '<a href="/post/index?tags=' + CGI.escape(CGI.unescapeHTML(tag)) + '">' + tag + '</a>'
    end
    str.gsub!(/[Pp]ost #(\d+)/, '<a href="/post/show/\1">post #\1</a>')
    str.gsub!(/[Ff]orum #(\d+)/, '<a href="/forum/show/\1">forum #\1</a>')
    str.gsub!(/[Cc]omment #(\d+)/, '<a href="/comment/show/\1">comment #\1</a>')
    str.gsub!(/[Pp]ool #(\d+)/, '<a href="/pool/show/\1">pool #\1</a>')
    str.gsub!(/\n/m, "<br>")
    str.gsub!(/\[b\](.+?)\[\/b\]/, '<strong>\1</strong>')
    str.gsub!(/\[i\](.+?)\[\/i\]/, '<em>\1</em>')
    str.gsub!(/\[spoilers?\](.+?)\[\/spoilers?\]/m, '<span class="spoiler">\1</span>')
    str.gsub!(/("[^"]+":(http:\/\/|\/)\S+|http:\/\/\S+)/m) do |link|
      if link =~ /^"([^"]+)":(.+)$/
        text = $1
        link = $2
      else
        text = link
      end
      
      if link =~ /([;,.!?\)\]<>])$/
        link.chop!
        ch = $1
      else
        ch = ""
      end

      link.gsub!(/"/, '&quot;')
      '<a href="' + link + '">' + text + '</a>' + ch
    end
    str
  end
  
  def parse_list(str, options = {})
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

  def parse(str, options = {})
    return "" if str.blank?
    
    # Make sure quote tags are surrounded by newlines
    
    unless options[:inline]
      str.gsub!(/\s*\[quote\]\s*/m, "\n\n[quote]\n\n")
      str.gsub!(/\s*\[\/quote\]\s*/m, "\n\n[/quote]\n\n")
    end
    
    str.gsub!(/(?:\r?\n){3,}/, "\n\n")
    str.strip!
    blocks = str.split(/(?:\r?\n){2}/)
    
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
          '<blockquote>'
        end
        
      when "[/quote]"
        if options[:inline]
          ""
        else
          '</blockquote>'
        end

      else
        '<p>' + parse_inline(block) + "</p>"
      end
    end

    html.join("")
  end
  
  module_function :parse_inline
  module_function :parse_list
  module_function :parse
end

