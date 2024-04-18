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
        elsif post_json.present?
          image_urls = post_json.dig("modules", "module_dynamic", "major", "opus", "pics").to_a.pluck("url")
          image_urls.to_a.compact.map { |u| Source::URL.parse(u).full_image_url || u }
        elsif article_image_urls.present?
          article_image_urls
        else
          [parsed_url.original_url]
        end
      end

      memoize def article_image_urls
        return [] unless article_json.present?

        html = Nokogiri::HTML5.fragment(artist_commentary_desc)
        html.css("img").pluck("data-src").map do |url|
          Source::URL.parse(URI.join("https://", url)).full_image_url || url
        end
      end

      def page_url
        work_page || parsed_url.page_url || parsed_referer&.page_url
      end

      def work_page
        if post_json["id_str"].present?
          "https://t.bilibili.com/#{post_json["id_str"]}"
        elsif article_json["cvid"].present?
          "https://www.bilibili.com/read/cv#{article_json["cvid"]}/"
        end
      end

      def artist_commentary_title
        post_json.dig("modules", "module_dynamic", "major", "opus", "title") || article_json.dig("readInfo", "title")
      end

      def artist_commentary_desc
        if post_json.present?
          post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes").to_a.map do |text_node|
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
        elsif article_json.present?
          article_json.dig("readInfo", "content")
        else
          nil
        end
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://t.bilibili.com")
      end

      def tags
        post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes").to_a.select do |n|
          n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
        end.map do |tag|
          tag_name = tag["text"].gsub(/(^#|#$)/, "")
          [tag_name, "https://t.bilibili.com/topic/name/#{Danbooru::URL.escape(tag_name)}"]
        end
      end

      def artist_name
        post_json.dig("modules", "module_author", "name") || article_json.dig("readInfo", "author", "name")
      end

      def tag_name
        "bilibili_#{artist_id}" if artist_id.present?
      end

      def other_names
        [artist_name].compact
      end

      def artist_id
        artist_id_from_data || parsed_url.artist_id || parsed_referer&.artist_id
      end

      def artist_id_from_data
        post_json.dig("modules", "module_author", "mid") || article_json.dig("readInfo", "author", "mid")
      end

      def profile_url
        "https://space.bilibili.com/#{artist_id}" if artist_id.present?
      end

      def t_work_id
        # for a repost this will be the ID of the repost, not the original one
        parsed_url.t_work_id || parsed_referer&.t_work_id
      end

      def article_id
        parsed_url.article_id || parsed_referer&.article_id
      end

      def http
        super.headers(
          Referer: parsed_url.page_url || parsed_referer&.page_url || "https://www.bilibili.com",
          "User-Agent": user_agent
        )
      end

      def user_agent
        # API requests fail unless we spoof the latest Firefox version. Firefox releases every 4 weeks.
        # https://whattrainisitnow.com/calendar/
        browser_ver = Time.use_zone("UTC") { 122 + ((Time.zone.today - Date.new(2024, 1, 23)).days.in_weeks.to_i / 4) }
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:#{browser_ver}.0) Gecko/20100101 Firefox/#{browser_ver}.0"
      end

      memoize def page
        url = parsed_url.page_url || parsed_referer&.page_url
        http.cache(1.minute).parsed_get(url)
      end

      memoize def post_json
        return {} if t_work_id.blank?

        data = http.cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?id=#{t_work_id}&features=itemOpusStyle") || {}

        if data.dig("data", "item", "orig", "id_str").present? # it means it's a repost
          data.dig("data", "item", "orig")
        else
          data.dig("data", "item").to_h
        end
      end

      memoize def article_json
        return {} if article_id.nil? || page.nil?

        script = page&.css("body script").to_a.map(&:text).grep(/window.__INITIAL_STATE__/).first.to_s
        json = script[/window.__INITIAL_STATE__=(.*);\(function\(\){[^"]*}\(\)\);\z/, 1]
        return {} if json.blank?

        JSON.parse(json).with_indifferent_access
      rescue JSON::ParserError
        {}
      end
    end
  end
end
