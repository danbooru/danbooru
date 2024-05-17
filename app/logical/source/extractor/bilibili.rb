# frozen_string_literal: true

# @see Source::URL::Bilibili
module Source
  class Extractor
    class Bilibili < Source::Extractor
      def image_urls
        if parsed_url&.full_image_url.present?
          [parsed_url.full_image_url]
        elsif parsed_url.image_url?
          [parsed_url.original_url]
        elsif post_json.present?
          image_urls = post_json.dig("modules", "module_dynamic", "major", "opus", "pics").to_a.pluck("url")
          image_urls.to_a.compact.map { |u| Source::URL.parse(u).full_image_url || u }
        elsif article_json.present?
          article_image_urls
        else
          []
        end
      end

      memoize def article_image_urls
        return [] unless article_json.present?

        artist_commentary_desc.to_s.parse_html.css("img").filter_map do |img|
          # Skip:
          #   <img data-src="//i0.hdslb.com/bfs/article/4adb9255ada5b97061e610b682b8636764fe50ed.png" class="cut-off-5">
          #   <img data-src="//i0.hdslb.com/bfs/article/card/1-1card458718717_web.png" width="1320" height="188" data-size="37499" aid="458718717" class="video-card nomal" type="nomal">
          #   <img data-src="//i0.hdslb.com/bfs/article/card/ef6b00f9d998c52e9a4bffb9051235c7ab288719.png" width="1320" height="224" data-size="44498" aid="20190469" class="article-card" type="normal">
          #   <img alt="琉绮RUKI立绘.png" width="280" height="522">
          #
          # Keep:
          #   <img data-src="//i0.hdslb.com/bfs/article/cf18da941f612502e994d8b9f991175dbfbbc7d9.png" width="650" height="180" data-size="11948" class="seamless" type="seamlessImage">
          #   <img data-src="//i0.hdslb.com/bfs/article/82f9cb60d3f83b73a7c550d3142d65bc772a2527.png" width="476" height="2112" data-size="533862">
          #   <img data-src="//i0.hdslb.com/bfs/article/watermark/ec0897d1aa461471149315f4b24e18a8a609853f.png" width="750" height="929" data-size="1486140">
          next if img["class"]&.match?(/card|cut-off/) || img["data-src"].blank?

          url = URI.join("https://", img["data-src"]).to_s
          Source::URL.parse(url).full_image_url || url
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
        if post_json.present?
          post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes").to_a.select do |n|
            n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
          end.map do |tag|
            tag_name = tag["text"].gsub(/(^#|#$)/, "")
            [tag_name, "https://t.bilibili.com/topic/name/#{Danbooru::URL.escape(tag_name)}"]
          end
        elsif article_json.present?
          article_json.dig("readInfo", "tags").to_a.map do |tag|
            [tag["name"], "https://search.bilibili.com/article?keyword=#{Danbooru::URL.escape(tag["name"])}"]
          end
        else
          []
        end
      end

      def display_name
        post_json.dig("modules", "module_author", "name") || article_json.dig("readInfo", "author", "name")
      end

      def tag_name
        "bilibili_#{artist_id}" if artist_id.present?
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
        script[/window.__INITIAL_STATE__=(.*);\(function\(\){[^"]*}\(\)\);\z/, 1]&.parse_json || {}
      end
    end
  end
end
