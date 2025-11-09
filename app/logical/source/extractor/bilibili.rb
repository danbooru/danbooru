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
          post_image_urls
        else
          []
        end
      end

      memoize def article_image_urls
        urls = []

        urls += article_json.dig("modules", "module_top", "display", "album", "pics").to_a.pluck("url")
        urls += article_json.dig("modules", "module_content", "paragraphs").to_a.select do |paragraph|
          paragraph["para_type"] == 2
        end.pluck("pic").pluck("pics").flatten.pluck("url")

        urls.compact.map { |u| Source::URL.parse(u).full_image_url || u }
      end

      memoize def post_image_urls
        urls = []

        urls += post_json.dig("modules", "module_dynamic", "major", "opus", "pics").to_a.pluck("url")
        urls += post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes").to_a.select do |node|
          node["type"] == "RICH_TEXT_NODE_TYPE_VIEW_PICTURE"
        end.pluck("pics").flatten.pluck("src")

        urls.compact.map { |u| Source::URL.parse(u).full_image_url || u }
      end

      def page_url
        work_page || parsed_url.page_url || parsed_referer&.page_url
      end

      def work_page
        if article_json["id_str"].present?
          "https://www.bilibili.com/opus/#{article_json["id_str"]}"
        elsif post_json["id_str"].present?
          if post_json.dig("basic", "jump_url").present?
            URI.join("https://", post_json.dig("basic", "jump_url")).to_s
          else
            "https://t.bilibili.com/#{post_json["id_str"]}"
          end
        end
      end

      def artist_commentary_title
        # Is modules.module_dynamic.title supported in t.bilibili.com/:id works?
        article_json.dig("modules", "module_title", "text") || post_json.dig("modules", "module_dynamic", "title") || post_json.dig("modules", "module_dynamic", "major", "opus", "title")
      end

      def artist_commentary_desc
        article_commentary_desc.presence || post_commentary_desc.presence
      end

      def article_commentary_desc
        article_json.dig("modules", "module_content", "paragraphs").to_a.map do |paragraph|
          case paragraph["para_type"]
          when 1
            nodes = paragraph.dig("text", "nodes")
          when 5
            nodes = paragraph.dig("list", "items").pluck("nodes").flatten
          else
            nodes = []
          end

          nodes.map do |text_node|
            case text_node["type"]
            when "TEXT_NODE_TYPE_WORD"
              text = text_node.dig("word", "words").gsub("\n", "<br>")
              text = "<strong>#{text}</strong>" if text_node.dig("word", "style", "bold")
              text
            when "TEXT_NODE_TYPE_RICH"
              rich = text_node["rich"]
              case rich["type"]
              when "RICH_TEXT_NODE_TYPE_BV", "RICH_TEXT_NODE_TYPE_TOPIC", "RICH_TEXT_NODE_TYPE_WEB"
                text = "<a href='#{URI.join("https://", rich["jump_url"])}'>#{rich["text"]}</a>"
              when "RICH_TEXT_NODE_TYPE_EMOJI"
                text = "<a href='#{rich.dig("emoji", "icon_url")}'>#{rich["text"]}</a>"
              when "RICH_TEXT_NODE_TYPE_AT"
                text = "<a href='https://space.bilibili.com/#{rich["rid"]}/dynamic'>#{rich["text"]}</a>"
              else
                text = rich["text"]
              end
            else
              text = ""
            end

            text = "<li>#{text}</li>" if paragraph["para_type"] == 5
            text
          end.join
        end.join("<br><br>")
      end

      def post_commentary_desc
        rich_text_nodes = post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes") || post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes")
        rich_text_nodes.to_a.map do |text_node|
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
        tag_names = article_json.dig("modules", "module_content", "paragraphs").to_a.select do |paragraph|
          paragraph["para_type"] == 1
        end.flat_map do |paragraph|
          paragraph.dig("text", "nodes").select do |text_node|
            text_node["type"] == "TEXT_NODE_TYPE_RICH" && text_node["rich"]["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
          end.map do |tag|
            tag.dig("rich", "text").gsub(/(^#|#$)/, "")
          end
        end

        tag_names += article_json.dig("modules", "module_extend", "items").to_a.pluck("text")

        tags = tag_names.map do |tag_name|
          [tag_name, "https://search.bilibili.com/all?keyword=#{Danbooru::URL.escape(tag_name)}"]
        end

        if article_json.dig("modules", "module_topic").present?
          tags << [
            article_json.dig("modules", "module_topic", "name"),
            "https://www.bilibili.com/v/topic/detail/?topic_id=#{article_json.dig("modules", "module_topic", "id")}",
          ].compact
        end

        tags
      end

      def post_tags
        rich_text_nodes = post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes") || post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes")
        rich_text_nodes.to_a.select do |n|
          n["type"] == "RICH_TEXT_NODE_TYPE_TOPIC"
        end.map do |tag|
          tag_name = tag["text"].gsub(/(^#|#$)/, "")
          if tag["jump_url"].present?
            # Chinese characters are escaped in `jump_url`.
            [tag_name, URI.join("https://", tag["jump_url"]).to_s]
          else
            [tag_name, "https://t.bilibili.com/topic/name/#{Danbooru::URL.escape(tag_name)}"]
          end
        end
      end

      def display_name
        article_json.dig("modules", "module_author", "name") || post_json.dig("modules", "module_author", "name")
      end

      def tag_name
        "bilibili_#{artist_id}" if artist_id.present?
      end

      def artist_id
        artist_id_from_data || parsed_url.artist_id || parsed_referer&.artist_id
      end

      def artist_id_from_data
        article_json.dig("modules", "module_author", "mid") || post_json.dig("modules", "module_author", "mid")
      end

      def profile_url
        "https://space.bilibili.com/#{artist_id}" if artist_id.present?
      end

      def t_work_id
        parsed_url.t_work_id || parsed_referer&.t_work_id
      end

      def article_id
        parsed_url.article_id || parsed_referer&.article_id
      end

      def user_agent
        # API requests fail unless we spoof the latest Firefox version. Firefox releases every 4 weeks.
        firefox_version = http.cache(5.minutes).parsed_get("https://whattrainisitnow.com/api/release/schedule/?version=release")&.dig("version")
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:#{firefox_version}) Gecko/20100101 Firefox/#{firefox_version}"
      end

      def buvid
        data = http.cache(5.minutes).parsed_get("https://api.bilibili.com/x/web-frontend/getbuvid")
        data.dig("data", "buvid")
      end

      memoize def post_json
        return {} if t_work_id.blank?

        data = http.headers("User-Agent": user_agent).cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/detail?id=#{t_work_id}&features=itemOpusStyle") || {}
        data.dig("data", "item").to_h
      end

      memoize def article_json
        opus_id = t_work_id
        if article_id.present?
          data = http.headers("User-Agent": user_agent).cache(1.minute).parsed_get("https://api.bilibili.com/x/article/view?id=#{article_id}") || {}
          opus_id = data.dig("data", "dyn_id_str")
        end
        return {} if opus_id.blank?

        data = http.headers("User-Agent": user_agent).cookies(buvid3: buvid).cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/detail?id=#{opus_id}&features=htmlNewStyle") || {}
        data = data.dig("data", "item").to_h

        modules = data["modules"]
        if modules.present?
          data["modules"] = modules.each {|mod| mod.delete("module_type")}.reduce({}, :merge)
        end

        data
      end
    end
  end
end
