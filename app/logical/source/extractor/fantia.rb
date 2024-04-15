# frozen_string_literal: true

class Source::Extractor
  class Fantia < Source::Extractor
    extend Memoist

    def self.enabled?
      Danbooru.config.fantia_session_id.present?
    end

    def match?
      Source::URL::Fantia === parsed_url
    end

    def image_urls
      if parsed_url.image_url?
        [full_image_for(parsed_url)].compact
      elsif work_type == "post"
        images_for_post.map { |url| full_image_for(url) }.compact.uniq
      elsif work_type == "product"
        images_for_product.map { |url| full_image_for(url) }.compact.uniq
      else
        []
      end
    end

    def full_image_for(url)
      parsed = Source::URL.parse(url)

      if parsed&.full_image_url.present?
        parsed.full_image_url
      elsif parsed&.downloadable?
        resp = http.head(parsed)
        resp.uri.to_s if resp.status == 200 && resp.mime_type != "text/html"
      else
        url
      end
    end

    def images_for_post
      return [] unless api_response.present?

      images = api_response.dig("post", "post_contents").to_a.map do |content|
        next if content["visible_status"] != "visible"

        case content["category"]
        when "photo_gallery"
          content["post_content_photos"].to_a.map { |i| i.dig("url", "original") }
        when "file"
          full_image_for("https://www.fantia.jp/#{content["download_uri"]}")
        when "blog"
          comment = JSON.parse(content["comment"]) rescue {}

          comment["ops"].to_a.pluck("insert").grep(Hash).filter_map do |node|
            node["image"] || node.dig("fantiaImage", "url")
          end
        end
      end.flatten.compact

      thumb_micro = api_response.dig("post", "thumb_micro")
      [thumb_micro, *images].compact
    end

    def images_for_product
      return [] unless work_type == "product"

      page&.css(".product-gallery-item .img-fluid").to_a.map do |element|
        element["src"] unless element["src"] =~ %r{/fallback/}
      end.compact
    end

    def page_url
      parsed_url.page_url || parsed_referer&.page_url
    end

    def tags
      case work_type
      when "post"
        api_response&.dig("post", "tags").to_a.map do |tag|
          [tag["name"], "https://fantia.jp/posts?tag=#{Danbooru::URL.escape(tag["name"])}"]
        end
      when "product"
        page&.css(".product-category a").to_a.map do |element|
          tag_name = element.text.delete_prefix("#")
          [tag_name, "https://fantia.jp/products?tag=#{Danbooru::URL.escape(tag_name)}"]
        end
      else
        []
      end
    end

    def artist_name
      case work_type
      when "post"
        api_response&.dig("post", "fanclub", "creator_name")
      when "product"
        # "⚡️電波暗室⚡️ (弱電波@JackDempa)"
        page&.at(".fanclub-name a")&.text&.slice(/\A(.*) \((.*)\)\z/, 2)
      end
    end

    def profile_url
      case work_type
      when "post"
        fanclub_id = api_response&.dig("post", "fanclub", "id")
        "https://fantia.jp/fanclubs/#{fanclub_id}" if fanclub_id.present?
      when "product"
        href = page&.at(".fanclub-name a")&.attr("href")
        URI.join("https://fantia.jp/", href).to_s if href.present?
      end
    end

    def artist_commentary_title
      case work_type
      when "post"
        api_response&.dig("post", "title")
      when "product"
        page&.at(".product-title")&.text
      end
    end

    def artist_commentary_desc
      case work_type
      when "post"
        api_response&.dig("post", "comment")
      when "product"
        page&.at(".product-description")&.text
      end
    end

    def dtext_artist_commentary_desc
      DText.from_plaintext(artist_commentary_desc)
    end

    def work_type
      parsed_url.work_type || parsed_referer&.work_type
    end

    def work_id
      parsed_url.work_id || parsed_referer&.work_id
    end

    memoize def page
      case work_type
      when "post"
        http.cache(1.minute).parsed_get("https://fantia.jp/posts/#{work_id}")
      when "product"
        http.cache(1.minute).parsed_get("https://fantia.jp/products/#{work_id}")
      end
    end

    memoize def csrf_token
      page&.css('meta[name="csrf-token"]')&.attr("content")&.value if work_type == "post"
    end

    memoize def api_response
      return {} unless work_type == "post" && csrf_token.present?

      http.cache(1.minute).headers(
        "X-CSRF-Token": csrf_token,
        "X-Requested-With": "XMLHttpRequest",
      ).parsed_get("https://fantia.jp/api/v1/posts/#{work_id}") || {}
    end

    def http
      super.cookies(_session_id: Danbooru.config.fantia_session_id)
    end
  end
end
