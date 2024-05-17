# frozen_string_literal: true

# @see Source::URL::Reddit
module Source
  class Extractor
    class Reddit < Source::Extractor
      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        elsif data.present?
          images = []
          images += [data.dig("media", "content")].compact unless crosspost? || data.dig("media", "type") == "embed"
          images += ordered_gallery_images
          images.compact.uniq.map { |url| Source::URL.parse(url)&.full_image_url || url }.compact
        else
          []
        end
      end

      def ordered_gallery_images
        gallery_images = data.dig("media", "mediaMetadata")

        gallery_order = data.dig("media", "gallery", "items").to_a.pluck("mediaId")
        gallery_order = data.dig("media", "richtextContent", "document").to_a.pluck("id").compact if gallery_order.blank?

        gallery_images.to_h.values_at(*gallery_order).compact.pluck("s").pluck("u")
      end

      def profile_url
        "https://www.reddit.com/user/#{username}" if username.present?
      end

      def page_url
        data["permalink"] || parsed_url.page_url || parsed_referer&.page_url
      end

      def tags
        return [] unless subreddit.present?

        data["flair"].to_a.pluck("text").compact_blank.uniq.map do |flair|
          [flair, %{https://www.reddit.com/r/#{subreddit}/?f=flair_name:"#{Danbooru::URL.escape(flair)}"}]
        end
      end

      def username
        username = data["author"] || parsed_url.username || parsed_referer&.username
        username unless username == "[deleted]"
      end

      def artist_commentary_title
        data["title"]
      end

      def artist_commentary_desc
        data.dig("media", "richtextContent", "document")&.to_json
      end

      def dtext_artist_commentary_desc
        DText.from_html(html_artist_commentary_desc, base_url: "https://www.reddit.com")
      end

      def html_artist_commentary_desc
        nodes = data.dig("media", "richtextContent", "document").to_a
        rich_text_to_html(nodes)
      end

      # Convert Reddit's rich text formatting language from JSON to HTML. The document is structured as a list of JSON
      # nodes, where each node has an element type ("e") and nested node content ("c"). Text nodes have "t" content and
      # an "f" array that denotes bold/italics/etc formatting tags as a list of character ranges.
      def rich_text_to_html(nodes)
        nodes.map do |node|
          case node["e"]
          in "raw"
            CGI.escapeHTML(node["t"])
          in "text"
            text_node_to_html(node["t"], node["f"])
          in "br"
            "<br>"
          in "hr"
            "<hr>"
          in "par"
            "<p>#{rich_text_to_html(node["c"])}</p>"
          in "li"
            "<li>#{rich_text_to_html(node["c"])}</li>"
          in "list"
            "<ul>#{rich_text_to_html(node["c"])}</ul>"
          in "blockquote"
            "<blockquote>#{rich_text_to_html(node["c"])}</blockquote>"
          in "code"
            "<pre>#{rich_text_to_html(node["c"])}</pre>"
          in "spoilertext"
            "<inline-spoiler>#{rich_text_to_html(node["c"])}</inline-spoiler>"
          in "h"
            level = node["l"] || "1"
            tag = "h#{level}"
            "<#{tag}>#{rich_text_to_html(node["c"])}</#{tag}>"
          in "r/"
            url = "https://www.reddit.com/r/#{Danbooru::URL.escape(node["t"])}/"
            %{<a href="#{CGI.escapeHTML(url)}">#{CGI.escapeHTML(url)}</a>}
          in "u/"
            url = "https://www.reddit.com/user/#{Danbooru::URL.escape(node["t"])}/"
            %{<a href="#{CGI.escapeHTML(url)}">#{CGI.escapeHTML(url)}</a>}
          in "link"
            %{<a href="#{CGI.escapeHTML(node["u"])}">#{CGI.escapeHTML(node["t"])}</a>}
          in "img"
            url = data.dig("media", "mediaMetadata", node["id"], "s", "u")
            url = Source::URL.parse(url).try(:full_image_url).to_s || url
            %{<img src="#{CGI.escapeHTML(url)}" alt="[image]">}
          in "table"
            "" # XXX Not supported
          else
            ""
          end
        end.join
      end

      # Convert a text node to HTML. `format_ranges` is a list of `[formatting_code, offset, length]` triples that
      # denote bold/italics/etc tags as (offset, length) ranges in the string.
      def text_node_to_html(text, format_ranges, formatting_codes: { 1 => :b, 2 => :em, 8 => :s, 32 => :sup, 64 => :code })
        return CGI.escapeHTML(text) if format_ranges.blank?

        output = "".dup

        # The list of active formatting tags. This contains e.g `:b` if we're inside a <b> tag.
        open_formatting_tags = [].to_set

        # The list of formatting tags used somewhere in this text.
        formats = format_ranges.map(&:first).map(&formatting_codes).compact

        # Output characters one at a time, adding <b> and </b> tags based on whether the current character should be
        # bold and whether it's already inside a <b> tag.
        text.chars.each_with_index do |char, i|
          # The list of formatting tags active for this character. This contains e.g. `:b` if this character should be in a <b> tag.
          active_formats = format_ranges.select { |_, offset, length| i.in?(offset...offset + length) }.map do |code, _, _|
            formatting_codes[code]
          end

          formats.each do |tag|
            # Output a <b> tag if this character is bold and we're not in a <b> tag.
            if active_formats.include?(tag) && !open_formatting_tags.include?(tag)
              output << "<#{tag}>"
              open_formatting_tags.add(tag)
            # Output a </b> tag if this character is not bold and we're in a <b> tag.
            elsif !active_formats.include?(tag) && open_formatting_tags.include?(tag)
              output << "</#{tag}>"
              open_formatting_tags.delete(tag)
            end
          end

          output << CGI.escapeHTML(char)
        end

        open_formatting_tags.each do |tag|
          output << "</#{tag}>"
        end

        output
      end

      def crosspost?
        data["crosspostParentId"].present?
      end

      def work_id
        if share_url.present?
          redirect_url = http.redirect_url(share_url)
          Source::URL.parse(redirect_url)&.work_id
        else
          parsed_url.work_id || parsed_referer&.work_id
        end
      end

      def share_url
        parsed_urls.find(&:share_id)
      end

      def api_url
        "https://www.reddit.com/gallery/#{work_id}" if work_id.present?
      end

      memoize def subreddit
        Source::URL.parse(data["permalink"]).try(:subreddit) || parsed_url.subreddit || parsed_referer&.subreddit
      end

      memoize def data
        html = http.cache(1.minute).parsed_get(api_url)

        data = html&.at("script#data").to_s[/\s({.*})/, 1]&.parse_json || {}
        data.dig("posts", "models", "t3_#{work_id}") || {}
      end
    end
  end
end
