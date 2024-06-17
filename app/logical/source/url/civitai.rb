# frozen_string_literal: true

module Source
  class URL::Civitai < Source::URL
    attr_reader :image_id, :uuid

    def self.match?(url)
      url.domain == "civitai.com"
    end

    def parse
      case [subdomain, domain, *path_segments]

      in _, "civitai.com", "images", image_id
        @image_id = image_id

      in ("image" | "images"), "civitai.com", "xG1nkqKTMzGDvpLrqFT7WA", uuid, *rest
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
      "https://civitai.com/images/#{image_id}" if image_id.present?
    end
  end
end
