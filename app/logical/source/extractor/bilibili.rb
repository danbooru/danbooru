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
        elsif article_json.present?
          article_image_urls
        elsif post_json.present?
          image_urls = post_json.dig("modules", "module_dynamic", "major", "opus", "pics").to_a.pluck(:url)
          image_urls.to_a.compact.map { |u| Source::URL.parse(u).full_image_url || u }
        else
          []
        end
      end

      memoize def article_image_urls
        urls = []

        urls += article_json.dig("detail", "modules", "module_top", "display", "album", "pics").to_a.pluck("url")
        urls += article_json.dig("detail", "modules", "module_content", "paragraphs").to_a.select do |paragraph|
          paragraph["para_type"] == 2
        end.pluck(:pic).pluck(:pics).flatten.pluck(:url)

        urls
      end

      def page_url
        work_page || parsed_url.page_url || parsed_referer&.page_url
      end

      def work_page
        if article_json["id"].present?
          "https://www.bilibili.com/opus/#{article_json["id"]}"
        elsif post_json["id_str"].present?
          "https://t.bilibili.com/#{post_json["id_str"]}"
        end
      end

      def artist_commentary_title
        article_json.dig("detail", "modules", "module_title", "text") || post_json.dig("modules", "module_dynamic", "title")
      end

      def artist_commentary_desc
        article_commentary_desc.presence || post_commentary_desc.presence
      end

      def article_commentary_desc
        article_json.dig("detail", "modules", "module_content", "paragraphs").to_a.map do |paragraph|
          nodes = case paragraph["para_type"]
          when 1
            paragraph.dig("text", "nodes")
          when 5
            paragraph.dig("list", "items").pluck("nodes").flatten
          else
            []
          end

          nodes.map do |text_node|
            text = case text_node["type"]
            when "TEXT_NODE_TYPE_WORD"
              text = text_node.dig("word", "words").gsub("\n", "<br>")
              text = "<strong>#{text}</strong>" if text_node.dig("word", "style", "bold")
              text
            when "TEXT_NODE_TYPE_RICH"
              rich = text_node["rich"]
              case rich["type"]
              when "RICH_TEXT_NODE_TYPE_BV", "RICH_TEXT_NODE_TYPE_TOPIC", "RICH_TEXT_NODE_TYPE_WEB"
                "<a href='#{URI.join("https://", rich["jump_url"])}'>#{rich["text"]}</a>"
              when "RICH_TEXT_NODE_TYPE_EMOJI"
                "<a href='#{rich.dig("emoji", "icon_url")}'>#{rich["text"]}</a>"
              when "RICH_TEXT_NODE_TYPE_AT"
                "<a href='https://space.bilibili.com/#{rich["rid"]}/dynamic'>#{rich["text"]}</a>"
              else
                rich["text"]
              end
            else
              ""
            end

            text = "<li>#{text}</li>" if paragraph["para_type"] == 5
            text
          end.join
        end.join("<br><br>")
      end

      def post_commentary_desc
        post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.map do |text_node|
          case text_node["type"]
          when "RICH_TEXT_NODE_TYPE_BV", "RICH_TEXT_NODE_TYPE_TOPIC", "RICH_TEXT_NODE_TYPE_WEB"
            %{<a href="#{URI.join("https://", text_node["jump_url"])}">#{text_node["text"]}</a>}
          when "RICH_TEXT_NODE_TYPE_EMOJI"
            %{<a href="#{text_node.dig("emoji", "icon_url")}">#{text_node["text"]}</a>}
          when "RICH_TEXT_NODE_TYPE_AT"
            %{<a href="https://space.bilibili.com/#{text_node["rid"]}/dynamic">#{text_node["text"]}</a>}
          else # RICH_TEXT_NODE_TYPE_TEXT (text), unrecognized nodes, etc.
            text_node["text"]
          end
        end.join("")
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc, base_url: "https://www.bilibili.com")
      end

      def tags
        article_tags.presence || post_tags.presence || []
      end

      def article_tags
        tag_names = article_json.dig("detail", "modules", "module_content", "paragraphs").to_a.select do |paragraph|
          paragraph["para_type"] == 1
        end.flat_map do |paragraph|
          paragraph.dig("text", "nodes").select do |text_node|
            text_node["type"] == "TEXT_NODE_TYPE_RICH" && text_node["rich"]["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
          end.map do |tag|
            tag.dig('rich', 'text').gsub(/(^#|#$)/, "")
          end
        end

        tag_names += article_json.dig("detail", "modules", "module_extend", "items").to_a.pluck("text")

        tags = tag_names.map do |tag_name|
          [tag_name, "https://search.bilibili.com/all?keyword=#{Danbooru::URL.escape(tag_name)}"]
        end

        if article_json.dig("detail", "modules", "module_topic").present?
          tags << [
            article_json.dig("detail", "modules", "module_topic", "name"),
            "https://www.bilibili.com/v/topic/detail/?topic_id=#{article_json.dig("detail", "modules", "module_topic", "id")}",
          ].compact
        end

        tags
      end

      def post_tags
        post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.select do |n|
          n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
        end.map do |tag|
          tag_name = tag["text"].gsub(/(^#|#$)/, "")
          [tag_name, "https://t.bilibili.com/topic/name/#{Danbooru::URL.escape(tag_name)}"]
        end
      end

      def display_name
        article_json.dig("detail", "modules", "module_author", "name") || post_json.dig("modules", "module_author", "name")
      end

      def tag_name
        "bilibili_#{artist_id}" if artist_id.present?
      end

      def artist_id
        artist_id_from_data || parsed_url.artist_id || parsed_referer&.artist_id
      end

      def artist_id_from_data
        article_json.dig("detail", "modules", "module_author", "mid") || post_json.dig("modules", "module_author", "mid")
      end

      def profile_url
        "https://space.bilibili.com/#{artist_id}" if artist_id.present?
      end

      def t_work_id
        parsed_url.t_work_id || parsed_referer&.t_work_id
      end

      def user_agent
        # API requests fail unless we spoof the latest Firefox version. Firefox releases every 4 weeks.
        firefox_version = http.cache(5.minutes).parsed_get("https://whattrainisitnow.com/api/release/schedule/?version=release")&.dig("version")
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:#{firefox_version}) Gecko/20100101 Firefox/#{firefox_version}"
      end

      memoize def page
        url = parsed_url.page_url || parsed_referer&.page_url
        http.cache(1.minute).parsed_get(url)
      end

      memoize def post_json
        return {} if t_work_id.blank?

        data = http.headers("User-Agent": user_agent).cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?id=#{t_work_id}&features=itemOpusStyle") || {}
        data.dig("data", "item").to_h
      end

      memoize def article_json
        script = page&.css("body script").to_a.map(&:text).grep(/window.__INITIAL_STATE__/).first.to_s
        data = script[/window.__INITIAL_STATE__=(.*);\(function\(\){[^"]*}\(\)\);\z/, 1]&.parse_json || {}

        modules = data.dig("detail", "modules")
        if modules.present?
          data['detail']['modules'] = modules.each {|mod| mod.delete("module_type")}.reduce({}, :merge)
        end

        data
      end
    end
  end
end
