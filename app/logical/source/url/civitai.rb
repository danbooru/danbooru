# frozen_string_literal: true

module Source
  class URL::Civitai < Source::URL
    attr_reader :image_id, :post_id, :uuid

    def self.match?(url)
      url.domain == "civitai.com"
    end

    def parse
      case [subdomain, domain, *path_segments]

      in _, "civitai.com", "images", image_id
        @image_id = image_id

      in _, "civitai.com", "posts", post_id
        @post_id = post_id

      in ("image" | "images" | "imagecache"), "civitai.com", "xG1nkqKTMzGDvpLrqFT7WA", uuid, *rest
        @uuid = uuid

      else
        nil
      end
    end

    def image_url?
      uuid.present?
    end

    def full_image_url
      "https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/#{uuid}/original=true" if uuid.present?
    end

    def page_url
      if image_id.present?
        "https://civitai.com/images/#{image_id}"
      elsif post_id.present?
        "https://civitai.com/posts/#{post_id}"
      end
    end
  end
end
