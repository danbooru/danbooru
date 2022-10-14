# frozen_string_literal: true

# @see Source::URL::Tumblr
class Source::Extractor
  class Tumblr < Source::Extractor
    def self.enabled?
      Danbooru.config.tumblr_consumer_key.present?
    end

    def match?
      Source::URL::Tumblr === parsed_url
    end

    def image_urls
      return [find_largest(parsed_url)].compact if parsed_url.image_url?

      assets = []

      case post[:type]
      when "photo"
        assets += post[:photos].map do |photo|
          sizes = [photo[:original_size]] + photo[:alt_sizes]
          biggest = sizes.max_by { |x| x[:width] * x[:height] }
          biggest[:url]
        end

      when "video"
        assets += [post[:video_url]]
      end

      assets += inline_images
      assets = assets.map { |url| find_largest(url) }
      assets.compact
    end

    def page_url
      parsed_url.page_url || parsed_referer&.page_url || post_url_from_image_html&.page_url
    end

    def profile_url
      parsed_url.profile_url || parsed_referer&.profile_url || post_url_from_image_html&.profile_url
    end

    def artist_commentary_title
      case post[:type]
      when "text", "link"
        post[:title]

      when "answer"
        "#{post[:asking_name]} asked: #{post[:question]}"

      else
        nil
      end
    end

    def artist_commentary_desc
      case post[:type]
      when "text"
        post[:body]

      when "link"
        post[:description]

      when "photo", "video"
        post[:caption]

      when "answer"
        post[:answer]

      else
        nil
      end
    end

    def tags
      post[:tags].to_a.map do |tag|
        [tag, "https://tumblr.com/tagged/#{CGI.escape(tag)}"]
      end.uniq
    end

    def normalize_tag(tag)
      tag = tag.tr("-", "_")
      super(tag)
    end

    def dtext_artist_commentary_desc
      DText.from_html(artist_commentary_desc).strip
    end

    def find_largest(image_url)
      parsed_image = Source::URL.parse(image_url)
      if parsed_image.full_image_url.present?
        image_url_html(parsed_image.full_image_url)&.at("img[src*='/#{parsed_image.directory}/']")&.[](:src)
      elsif parsed_image.variants.present?
        # Look for the biggest available version on media.tumblr.com. A bigger version may or may not exist.
        parsed_image.variants.find { |variant| http_exists?(variant) } || image_url
      else
        parsed_image.original_url
      end
    end

    def post_url_from_image_html
      return nil unless parsed_url.image_url? && parsed_url.file_ext&.in?(%w[jpg png pnj gif])

      extracted = image_url_html(parsed_url)&.at("[href*='/post/']")&.[](:href)
      Source::URL.parse(extracted)
    end
    memoize :post_url_from_image_html

    def image_url_html(image_url)
      resp = http.cache(1.minute).headers(accept: "text/html").get(image_url)
      return nil if resp.code != 200 || resp.mime_type != "text/html"
      resp.parse
    end

    def inline_images
      html = Nokogiri::HTML5.fragment(artist_commentary_desc)
      html.css("img").map { |node| node["src"] }
    end

    def artist_name
      parsed_url.blog_name || parsed_referer&.blog_name || post_url_from_image_html&.try(:blog_name)  # Don't crash with custom domains
    end

    def work_id
      parsed_url.work_id || parsed_referer&.work_id || post_url_from_image_html&.try(:work_id)
    end

    def api_response
      return {} unless self.class.enabled?
      return {} unless artist_name.present? && work_id.present?

      response = http.cache(1.minute).get(
        "https://api.tumblr.com/v2/blog/#{artist_name}/posts",
        params: { id: work_id, api_key: Danbooru.config.tumblr_consumer_key }
      )

      return {} if response.code != 200
      response.parse.with_indifferent_access
    end
    memoize :api_response

    def post
      api_response.dig(:response, :posts)&.first || {}
    end
  end
end
