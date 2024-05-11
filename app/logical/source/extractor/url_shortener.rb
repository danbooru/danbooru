# frozen_string_literal: true

# Extractor for URL shorteners such as bit.ly or t.co.
#
# TODO: Add more shorteners from https://wiki.archiveteam.org/index.php/URLTeam. Use data dumps to unshorten dead URLs?
class Source::Extractor::URLShortener < Source::Extractor
  delegate :page_url, :profile_url, :artist_name, :tag_name, :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

  def image_urls
    sub_extractor&.image_urls || []
  end

  def other_names
    sub_extractor&.other_names || []
  end

  def profile_urls
    sub_extractor&.profile_urls || []
  end

  def tags
    sub_extractor&.tags || []
  end

  def artists
    sub_extractor&.artists || []
  end

  memoize def sub_extractor
    redirect_url&.extractor(parent_extractor: self)
  end

  memoize def redirect_url
    # In case the URL leads to a chain of URL shorteners, don't go more than five redirects deep.
    return nil if parent_extractors.grep(Source::Extractor::URLShortener).size > 5

    response = http.no_follow.head(parsed_url.redirect_url)
    redirect_url = response.headers["Location"] if response.status.redirect?
    redirect_url = URI.join(parsed_url.site, redirect_url) if redirect_url&.starts_with?("/")
    redirect_url = Source::URL.parse(redirect_url)

    redirect_url unless bad_redirect?(redirect_url)
  end

  def bad_redirect?(location)
    case parsed_url.domain

    # amzn.to returns a 302 redirect to http://www.amazon.com on error.
    in "amzn.to"
      location&.host == "www.amazon.com"

    # ow.ly returns a 301 relative redirect to /url/invalid on error.
    in "ow.ly"
      location&.host == "ow.ly" && location.path == "/url/invalid"

    # pin.it returns a redirect to https://api.pinterest.com/url_shortener/#{id}/redirect/None or https://www.pinterest.com on error.
    in "pin.it"
      location&.host == "api.pinterest.com" || location.to_s == "https://www.pinterest.com"

    else
      false
    end
  end

  def http
    case parsed_url.domain
    in "bit.ly" | "j.mp" | "t.co" | "twitter.com"
      # Don't use a browser user agent for these shorteners because then we get a HTML response instead of a 301 redirect.
      super.headers("User-Agent": "curl/8.2.1")
    else
      super
    end
  end
end
