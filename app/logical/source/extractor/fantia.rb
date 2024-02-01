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
      return [parsed_url.full_image_url] if parsed_url.full_image_url.present?
      return [image_from_downloadable(parsed_url)] if parsed_url.downloadable?

      images = images_for_post.presence || images_for_product.presence || []

      full_images = images.compact.map do |image|
        parsed = Source::URL.parse(image)
        if parsed&.full_image_url.present?
          parsed.full_image_url
        elsif parsed&.downloadable?
          image_from_downloadable(parsed)
        else
          image
        end
      end
      full_images.compact.uniq
    end

    def image_from_downloadable(url)
      resp = http.head(url)
      return url if resp.status != 200
      resp.uri.to_s
    end

    def images_for_post
      return [] unless api_response.present?

      images = api_response.dig("post", "post_contents").to_a.map do |content|
        next if content["visible_status"] != "visible"

        case content["category"]
        when "photo_gallery"
          content["post_content_photos"].to_a.map { |i| i.dig("url", "original") }
        when "file"
          image_from_downloadable("https://www.fantia.jp/#{content["download_uri"]}")
        when "blog"
          comment = JSON.parse(content["comment"]) rescue {}
          comment["ops"].to_a.pluck("insert").compact.filter_map do |node|
            next unless node.is_a?(Hash)
            next node["image"] if node.key?("image")
            next node["fantiaImage"]["url"] if node.key?("fantiaImage")
          end
        end
      end.flatten.compact

      thumb_micro = api_response.dig("post", "thumb_micro")
      [thumb_micro, *images].compact
    end

    def images_for_product
      html_response&.css(".product-gallery-item .img-fluid").to_a.map do |element|
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
          [tag["name"], "https://fantia.jp/posts?tag=#{tag["name"]}"]
        end
      when "product"
        html_response&.css(".product-category a").to_a.map do |element|
          tag_name = element.text.delete_prefix("#")
          [tag_name, "https://fantia.jp/products?product_category=##{tag_name}"]
        end
      else
        []
      end
    end

    def other_names
      case work_type
      when "post"
        [api_response&.dig("post", "fanclub", "creator_name")].compact
      when "product"
        [html_response&.at(".fanclub-name a")&.text].compact
      end
    end

    def profile_url
      case work_type
      when "post"
        fanclub_id = api_response&.dig("post", "fanclub", "id")
        return unless fanclub_id.present?
        "https://fantia.jp/fanclubs/#{fanclub_id}"
      when "product"
        href = html_response&.at(".fanclub-name a")&.[]("href")
        return unless href.present?
        URI.join("https://fantia.jp/", href).to_s
      end
    end

    def artist_commentary_title
      case work_type
      when "post"
        api_response&.dig("post", "title")
      when "product"
        html_response&.at(".product-title")&.text
      end
    end

    def artist_commentary_desc
      case work_type
      when "post"
        api_response&.dig("post", "comment")
      when "product"
        html_response&.at(".product-description")&.text
      end
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc)
    end

    def work_type
      parsed_url.work_type || parsed_referer&.work_type
    end

    def work_id
      parsed_url.work_id || parsed_referer&.work_id
    end

    memoize def post_page
      return nil unless work_type == "post"
      http.cache(1.minute).parsed_get("https://fantia.jp/posts/#{work_id}")
    end

    memoize def csrf_token
      post_page&.css('meta[name="csrf-token"]')&.attr("content")&.value
    end

    memoize def api_response
      return {} unless work_type == "post" && csrf_token.present?
      api_url = "https://fantia.jp/api/v1/posts/#{work_id}"

      http.cache(1.minute).headers(
        "X-CSRF-Token": csrf_token,
        "X-Requested-With": "XMLHttpRequest",
      ).parsed_get(api_url) || {}
    end

    memoize def html_response
      return nil unless work_type == "product"
      http.cache(1.minute).parsed_get("https://fantia.jp/products/#{work_id}")
    end

    def http
      super.cookies(_session_id: Danbooru.config.fantia_session_id)
    end
  end
end
