# frozen_string_literal: true

# @see Source::URL::TwitPic
module Sources::Strategies
  class TwitPic < Base
    def match?
      Source::URL::TwitPic === parsed_url
    end

    def normalize_for_source
      parsed_url.page_url || url
    end
  end
end
