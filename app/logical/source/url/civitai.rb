# frozen_string_literal: true

module Source
  class URL::Civitai < Source::URL
    attr_reader :image_id, :uuid, :width, :filename

    def self.match?(url)
      url.domain == "civitai.com"
    end

    def parse
      case [subdomain, domain, *path_segments]

      in _, "civitai.com", "images", image_id
        @image_id = image_id

      in "images", "civitai.com", "xG1nkqKTMzGDvpLrqFT7WA", uuid, /width=(\d+)/ => width, filename
        @uuid = uuid
        @width = width
        @filename = filename

      else
        nil
      end
    end

    def image_url?
      uuid.present? && filename.present?
    end

    def page_url
      "https://civitai.com/images/#{image_id}" if image_id.present?
    end
  end
end
