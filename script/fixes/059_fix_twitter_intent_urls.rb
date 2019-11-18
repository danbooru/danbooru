#!/usr/bin/env ruby

require_relative "../../config/environment"

# https://github.com/r888888888/danbooru/issues/4065
def fix_twitter_intent_urls
  ArtistUrl.without_timeout do
    urls = ArtistUrl.where(normalized_url: "http://twitter.com/intent/")
    urls.update_all("normalized_url = regexp_replace(url, '^https', 'http') || '/'")
  end
end
