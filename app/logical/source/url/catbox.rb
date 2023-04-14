# frozen_string_literal: true

module Source
  class URL::Catbox < Source::URL
    attr_reader :file_id, :service

    def self.match?(url)
      url.domain == "catbox.moe"
    end

    def parse
      case [subdomain, domain, *path_segments]

      in ("files" | "litterbox") => service, "catbox.moe", file_id
        @service = service
        @file_id = file_id

      else
        nil
      end
    end
  end
end
