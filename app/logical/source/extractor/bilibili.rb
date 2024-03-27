# frozen_string_literal: true

# @see Source::URL::Bilibili
module Source
  class Extractor
    class Bilibili < Source::Extractor
      def match?
        Source::URL::Bilibili === parsed_url
      end

      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif data.present?
          image_urls = data.dig("modules", "module_dynamic", "major", "draw", "items").to_a.pluck("src")
          image_urls.to_a.compact.map { |u| Source::URL.parse(u).full_image_url || u }
        elsif article_id.present?
          page&.search("#article-content img").to_a.pluck("data-src").compact.map { |u| Source::URL.parse(URI.join("https://", u)).full_image_url || u }
        else
          [parsed_url.original_url]
        end
      end

      def page_url
        t_work_page || parsed_url.page_url || parsed_referer&.page_url
      end

      def t_work_page
        return unless t_work_id.present?
        "https://t.bilibili.com/#{data["id_str"]}"
      end

      def artist_commentary_title
        if article_id.present?
          page&.at(".article-container .title")&.text&.squish&.strip
        end
      end

      def artist_commentary_desc
        if t_work_id.present?
          data.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.map do |text_node|
            case text_node["type"]
            when "RICH_TEXT_NODE_TYPE_BV", "RICH_TEXT_NODE_TYPE_TOPIC", "RICH_TEXT_NODE_TYPE_WEB"
              "<a href='#{URI.join("https://", text_node["jump_url"])}'>#{text_node["text"]}</a>"
            when "RICH_TEXT_NODE_TYPE_EMOJI"
              "<a href='#{text_node.dig("emoji", "icon_url")}'>#{text_node["text"]}</a>"
            when "RICH_TEXT_NODE_TYPE_AT"
              "<a href='https://space.bilibili.com/#{text_node["rid"]}/dynamic'>#{text_node["text"]}</a>"
            else # RICH_TEXT_NODE_TYPE_TEXT (text), unrecognized nodes, etc.
              text_node["text"]
            end
          end.join
        elsif article_id.present?
          page&.at("#article-content")&.to_html
        end
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc)
      end

      def tags
        data.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.select do |n|
          n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
        end.map do |tag|
          tag_name = tag["text"].gsub(/(^#|#$)/, "")
          [tag_name, "https://t.bilibili.com/topic/name/#{tag_name}"]
        end
      end

      def artist_name
        if t_work_id.present?
          data.dig("modules", "module_author", "name")
        elsif article_id.present?
          page&.at(".article-container .up-name")&.text&.squish&.strip
        end
      end

      def tag_name
        return unless artist_id.present?
        "bilibili_#{artist_id}"
      end

      def other_names
        [artist_name].compact
      end

      def artist_id
        artist_id_from_data || parsed_url.artist_id || parsed_referer&.artist_id
      end

      def artist_id_from_data
        if t_work_id.present?
          data.dig("modules", "module_author", "mid")
        elsif article_id.present?
          artist_url = page&.at(".article-container .up-name")&.[]("href")
          Source::URL.parse(URI.join("https://", artist_url))&.artist_id
        end
      end

      def profile_url
        return nil if artist_id.blank?
        "https://space.bilibili.com/#{artist_id}"
      end

      def t_work_id
        # for a repost this will be the ID of the repost, not the original one
        parsed_url.t_work_id || parsed_referer&.t_work_id
      end

      def article_id
        parsed_url.article_id || parsed_referer&.article_id
      end

      def http
        browser_ver = 109 + (Date.today - Date.new(2023, 1, 18)).days.in_weeks.to_i / 4
        browser_ua = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:#{browser_ver}.0) Gecko/20100101 Firefox/#{browser_ver}.0"

        super.headers(
          Referer: parsed_url.page_url || parsed_referer&.page_url || "https://www.bilibili.com",
          "User-Agent": browser_ua,
        )
      end

      memoize def page
        http.cache(1.minute).parsed_get(page_url)
      end

      memoize def data
        return {} if t_work_id.blank?

        data = http.cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?timezone_offset=-60&id=#{t_work_id}") || {}

        if data.dig("data", "item", "orig", "id_str").present? # it means it's a repost
          data.dig("data", "item", "orig")
        else
          data.dig("data", "item").to_h
        end
      end
    end
  end
end
