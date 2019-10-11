require 'cgi'
require 'uri'

class DText
  MENTION_REGEXP = /(?<=^| )@\S+/

  def self.format_text(text, data: nil, **options)
    data = preprocess([text]) if data.nil?
    html = DTextRagel.parse(text, **options)
    html = postprocess(html, *data)
    html
  rescue DTextRagel::Error => e
    ""
  end

  def self.preprocess(dtext_messages)
    names = dtext_messages.map { |message| parse_wiki_titles(message) }.flatten.uniq
    wiki_pages = WikiPage.where(title: names)
    tags = Tag.where(name: names)

    [wiki_pages, tags]
  end

  def self.postprocess(html, wiki_pages, tags)
    fragment = Nokogiri::HTML.fragment(html)

    fragment.css("a.dtext-wiki-link").each do |node|
      name = node["href"][%r!\A/wiki_pages/show_or_new\?title=(.*)\z!i, 1]
      name = CGI.unescape(name)
      name = WikiPage.normalize_title(name)
      wiki = wiki_pages.find { |wiki| wiki.title == name }
      tag = tags.find { |tag| tag.name == name }

      if wiki.blank?
        node["class"] += " dtext-wiki-does-not-exist"
        node["title"] = "This wiki page does not exist"
      end

      if WikiPage.is_meta_wiki?(name)
        # skip (meta wikis aren't expected to have a tag)
      elsif tag.blank?
        node["class"] += " dtext-tag-does-not-exist"
        node["title"] = "This wiki page does not have a tag"
      elsif tag.post_count <= 0
        node["class"] += " dtext-tag-empty"
        node["title"] = "This wiki page does not have a tag"
      else
        node["class"] += " tag-type-#{tag.category}"
      end
    end

    fragment.to_s
  end

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

  def self.parse_wiki_titles(text)
    html = DTextRagel.parse(text)
    fragment = Nokogiri::HTML.fragment(html)

    titles = fragment.css("a.dtext-wiki-link").map do |node|
      title = node["href"][%r!\A/wiki_pages/show_or_new\?title=(.*)\z!i, 1]
      title = CGI.unescape(title)
      title = WikiPage.normalize_title(title)
      title
    end
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

  def self.strip_dtext(dtext)
    html = DTextRagel.parse(dtext)
    text = to_plaintext(html)
    text
  end

  def self.to_plaintext(html)
    text = from_html(html) do |node|
      case node.name
      when "a", "strong", "em", "u", "s", "h1", "h2", "h3", "h4", "h5", "h6"
        node.name = "span"
        node.content = node.text
      when "blockquote"
        node.name = "span"
        node.content = to_plaintext(node.inner_html).gsub(/^/, "> ")
      end
    end

    text = text.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
  end

  def self.from_html(text, inline: false, &block)
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
        title = from_html(element.inner_html, inline: true, &block).strip
        url = element["href"]
        %("#{title}":[#{url}]) if title.present? && url.present?
      when "img"
        alt_text = element.attributes["title"] || element.attributes["alt"] || ""
        src = element["src"]

        if inline
          alt_text
        elsif alt_text.present? && src.present?
          %("#{alt_text}":[#{src}]\n\n)
        else
          ""
        end
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
