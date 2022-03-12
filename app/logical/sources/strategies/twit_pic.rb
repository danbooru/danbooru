# frozen_string_literal: true

# @see Source::URL::TwitPic
module Sources::Strategies
  class TwitPic < Base
    def match?
      parsed_url&.site_name == "TwitPic"
    end

    def normalize_for_source
      parsed_url.page_url || url
    end
  end
end
