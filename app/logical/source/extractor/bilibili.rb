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
          if t_work_id.present?
            image_urls = data.dig("modules", "module_dynamic", "major", "draw", "items").to_a.pluck("src")
          elsif h_work_id.present?
            image_urls = data.dig("item", "pictures").to_a.pluck("img_src")
          end
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
          data.dig("modules", "module_dynamic", "desc", "rich_text_nodes").map do |text_node|
            case text_node["type"]
            when "RICH_TEXT_NODE_TYPE_BV"
              "<a href='#{URI.join("https://", text_node["jump_url"])}'>#{text_node["text"]}</a>"
            when "RICH_TEXT_NODE_TYPE_EMOJI"
              " #{text_node.dig("emoji", "icon_url")} "
            else # RICH_TEXT_NODE_TYPE_AT (mentions), RICH_TEXT_NODE_TYPE_TEXT (text), RICH_TEXT_NODE_TYPE_TOPIC (hashtags)
              text_node["text"]
            end
          end.join
        elsif h_work_id.present?
          data.dig("item", "description")
        elsif article_id.present?
          page&.at("#article-content")&.to_html
        end
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc)
      end

      def tags
        if t_work_id.present?
          tag_list = data.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.select { |n| n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC" }.map { |tag| tag["text"].gsub(/(^#|#$)/, "") }
        elsif h_work_id.present?
          tag_list = data.dig("item", "tags").to_a.pluck(:tag)
        else # bilibili.com/read/:id posts have no tags that I could find
          return []
        end

        tag_list.map { |tag| [tag, "https://t.bilibili.com/topic/name/#{tag}"] }
      end

      def artist_name
        if t_work_id.present?
          data.dig("modules", "module_author", "name")
        elsif h_work_id.present?
          data.dig("user", "name")
        elsif article_id.present?
          page&.at(".article-container .up-name")&.text&.squish&.strip
        end
      end

      def tag_name
        return unless artist_id.present?
        "bilibili_#{artist_id}"
      end

      def artist_id
        artist_id_from_data || parsed_url.artist_id || parsed_referer&.artist_id
      end

      def artist_id_from_data
        if t_work_id.present?
          data.dig("modules", "module_author", "mid")
        elsif h_work_id.present?
          data.dig("user", "uid")
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

      def h_work_id
        parsed_url.h_work_id || parsed_referer&.h_work_id
      end

      def article_id
        parsed_url.article_id || parsed_referer&.article_id
      end

      def page
        return unless page_url.present?
        response = http.cache(1.minute).get(page_url)
        return response.parse unless response.status != 200
      end

      def get_json(url)
        response = http.cache(1.minute).get(url)
        return {} unless response.status == 200
        JSON.parse(response).with_indifferent_access
      rescue JSON::ParserError
        {}
      end

      def data
        if t_work_id.present?
          data = get_json("https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?timezone_offset=-60&id=#{t_work_id}")
          if data.dig("data", "item", "orig", "id_str").present? # it means it's a repost
            data.dig("data", "item", "orig")
          else
            data.dig("data", "item").to_h
          end
        elsif h_work_id.present?
          data = get_json("https://api.vc.bilibili.com/link_draw/v1/doc/detail?doc_id=#{h_work_id}")
          data["data"].to_h
        else
          {}
        end
      end

      memoize :data, :page
    end
  end
end
