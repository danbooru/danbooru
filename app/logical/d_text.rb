require 'cgi'
require 'uri'

class DText
  MENTION_REGEXP = /(?<=^| )@\S+/

  def self.quote(message, creator_name)
    stripped_body = DText.strip_blocks(message, "quote")
    "[quote]\n#{creator_name} said:\n\n#{stripped_body}\n[/quote]\n\n"
  end

  def self.parse_mentions(text)
    text = strip_blocks(text.to_s, "quote")

    names = text.scan(MENTION_REGEXP).map do |mention|
      mention.gsub(/(?:^\s*@)|(?:[:;,.!?\)\]<>]$)/, "")
    end

    names.uniq
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

  def self.from_html(text, &block)
    html = Nokogiri::HTML.fragment(text)

    dtext = html.children.map do |element|
      block.call(element) if block.present?

      case element.name
      when "text"
        element.content.gsub(/(?:\r|\n)+$/, "")
      when "br"
        "\n"
      when "p", "ul", "ol"
        from_html(element.inner_html, &block).strip + "\n\n"
      when "blockquote"
        "[quote]#{from_html(element.inner_html, &block).strip}[/quote]\n\n" if element.inner_html.present?
      when "small", "sub"
        "[tn]#{from_html(element.inner_html, &block)}[/tn]" if element.inner_html.present?
      when "b", "strong"
        "[b]#{from_html(element.inner_html, &block)}[/b]" if element.inner_html.present?
      when "i", "em"
        "[i]#{from_html(element.inner_html, &block)}[/i]" if element.inner_html.present?
      when "u"
        "[u]#{from_html(element.inner_html, &block)}[/u]" if element.inner_html.present?
      when "s", "strike"
        "[s]#{from_html(element.inner_html, &block)}[/s]" if element.inner_html.present?
      when "li"
        "* #{from_html(element.inner_html, &block)}\n" if element.inner_html.present?
      when "h1", "h2", "h3", "h4", "h5", "h6"
        hN = element.name
        title = from_html(element.inner_html, &block)
        "#{hN}. #{title}\n\n"
      when "a"
        title = from_html(element.inner_html, &block).strip
        url = element["href"]
        %("#{title}":[#{url}]) if title.present? && url.present?
      when "img"
        element.attributes["title"] || element.attributes["alt"] || ""
      when "comment"
        # ignored
      else
        from_html(element.inner_html, &block)
      end
    end.join

    dtext
  end

  # extract the first paragraph `needle` occurs in.
  def self.excerpt(dtext, needle)
    dtext = dtext.gsub(/\r\n|\r|\n/, "\n")
    excerpt = ActionController::Base.helpers.excerpt(dtext, needle, separator: "\n\n", radius: 1, omission: "")
    excerpt
  end
end
