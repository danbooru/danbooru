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

      def work_id_from_data
        article_json["id_str"] || post_json["id_str"]
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

      # https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/opus/rich_text_nodes.md
      def rich_text_node(rich)
        text = CGI.escapeHTML(rich["text"])
        case rich["type"]
        when "RICH_TEXT_NODE_TYPE_BV", "RICH_TEXT_NODE_CV", "RICH_TEXT_NODE_TYPE_AV", "RICH_TEXT_NODE_TYPE_TOPIC", "RICH_TEXT_NODE_TYPE_WEB", "RICH_TEXT_NODE_TYPE_GOODS"
          %{<a href="#{CGI.escapeHTML(URI.join("https://", rich["jump_url"]))}">#{text}</a>}
        when "RICH_TEXT_NODE_TYPE_EMOJI"
          %{<a href="#{rich.dig("emoji", "icon_url")}">#{text}</a>}
        when "RICH_TEXT_NODE_TYPE_AT"
          %{<a href="https://space.bilibili.com/#{rich["rid"]}/dynamic">#{text}</a>}
        when "RICH_TEXT_NODE_TYPE_LOTTERY"
          %{<a href="https://www.bilibili.com/h5/lottery/result?business_type=1&business_id=#{work_id_from_data}&isWeb=1">#{text}</a>}
        when "RICH_TEXT_NODE_TYPE_VOTE"
          %{<a href="https://t.bilibili.com/vote/h5/index/#/result?vote_id=#{rich["rid"]}">#{text}</a>}
        when "RICH_TEXT_NODE_TYPE_VIEW_PICTURE"
          ""
        else # RICH_TEXT_NODE_TYPE_TEXT (text), unrecognized nodes, etc.
          text.gsub("\n", "<br>")
        end
      end

      # https://github.com/SocialSisterYi/bilibili-API-collect/blob/18bd4b22c552dc468e47949e449ddc298420c9e6/docs/opus/features.md#module_type_content
      def article_text_node(node)
        case node["type"]
        when "TEXT_NODE_TYPE_WORD"
          # Unsupported in Danbooru Dtext: `bg_style`, `color`
          text = CGI.escapeHTML(node.dig("word", "words")).gsub("\n", "<br>")
          case node.dig("word", "font_level")
          when "xxLarge"
            text = "<h4>#{text}</h4>"
          when "xLarge"
            text = "<h5>#{text}</h5>"
          else # regular
            text = "<b>#{text}</b>" if node.dig("word", "style", "bold")
          end
          text = "<s>#{text}</s>" if node.dig("word", "style", "strikethrough")
          text = "<i>#{text}</i>" if node.dig("word", "style", "italic")
          text
        when "TEXT_NODE_TYPE_RICH"
          rich_text_node(node["rich"])
        else # TEXT_NODE_TYPE_FORMULA
          ""
        end
      end

      def link_card(card, type)
        case type
        when "goods"
          text = card["items"].map do |item|
            %{<a href="#{CGI.escapeHTML(item["jump_url"])}">#{CGI.escapeHTML(item["name"])}</a>}
          end.join("<br>")
        when "vote"
          text = %{<a href="https://t.bilibili.com/vote/h5/index/#/result?vote_id=#{card["vote_id"]}">#{card["desc"]}</a>}
        else
          text = card["title"].to_s
          if card["jump_url"].present?
            jump_url = CGI.escapeHTML(URI.join("https://", card["jump_url"]))
            if text.blank?
              text = jump_url.to_s
            end
            text = %{<a href="#{jump_url}">#{text}</a>}
          end
        end

        if card["head_text"].present?
          text = "<small>#{card["head_text"]}</small><br>#{text}"
        end
        text
      end

      def article_commentary_desc
        article_json.dig("modules", "module_content", "paragraphs").to_a.map do |paragraph|
          # Unsupported in Danbooru Dtext: `align`
          case paragraph["para_type"]
          when 1, 4
            text = paragraph.dig("text", "nodes").map do |node|
              article_text_node(node)
            end.join
            text = "<blockquote>#{text}</blockquote>" if paragraph["para_type"] == 4
            text
          when 2
            if paragraph.dig("pic", "style") != 1 # isAlbum
              paragraph.dig("pic", "pics").map do |pic|
                %{<a href="#{pic["url"]}">[Image]</a>}
              end.join
            end
          when 3
            "<hr>"
          when 5
            last_level = 0
            text = paragraph.dig("list", "items").map do |item|
              text = item["nodes"].map do |node|
                article_text_node(node)
              end.join
              text = "#{item["order"]}. #{text}" if paragraph.dig("list", "style") == 1

              if item["level"] > last_level
                text = "#{"<ul><li>" * (item["level"] - last_level)}#{text}"
              elsif item["level"] < last_level
                text = "#{"</li></ul>" * (last_level - item["level"])}<li>#{text}"
              else
                text = "</li><li>#{text}"
              end
              last_level = item["level"]

              text
            end.join
            "#{text}#{"</li></ul>" * last_level}"
          when 6
            case paragraph.dig("link_card", "card", "type")
            when "LINK_CARD_TYPE_ITEM_NULL"
              paragraph.dig("link_card", "card", "item_null", "text")
            when "LINK_CARD_TYPE_UPOWER_LOTTERY" # paywalled?
              ""
            else
              type = paragraph.dig("link_card", "card", "type").gsub("LINK_CARD_TYPE_", "").downcase
              link_card(paragraph.dig("link_card", "card", type), type)
            end
          when 7
            # `lang`?
            "<pre>#{CGI.escapeHTML(paragraph.dig("code", "content"))}</pre>"
          when 8
            paragraph.dig("heading", "nodes").map do |node|
              article_text_node(node)
            end.join
          else
            ""
          end
        end.join("<br><br>")
      end

      def post_commentary_desc
        rich_text_nodes = post_json.dig("modules", "module_dynamic", "desc", "rich_text_nodes") || post_json.dig("modules", "module_dynamic", "major", "opus", "summary", "rich_text_nodes")
        rich_text_nodes.to_a.map do |text_node|
          rich_text_node(text_node)
        end.join
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

      def buvid3
        data = http.cache(5.minutes).parsed_get("https://api.bilibili.com/x/web-frontend/getbuvid")
        data&.dig("data", "buvid")
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

        data = http.headers("User-Agent": user_agent).cookies(buvid3: buvid3).cache(1.minute).parsed_get("https://api.bilibili.com/x/polymer/web-dynamic/v1/opus/detail?id=#{opus_id}&features=htmlNewStyle") || {}
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
