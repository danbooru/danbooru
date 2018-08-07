module Sources::Strategies
  class Twitter < Base
    PAGE = %r!^https?://(?:mobile\.)?twitter\.com!i
    ASSET = %r{^(https?://(?:video|pbs)\.twimg\.com/media/)}i

    def self.match?(*urls)
      urls.compact.any? { |x| self.status_id_from_url(x).present? || x =~ ASSET}
    end

    # https://twitter.com/i/web/status/943446161586733056
    # https://twitter.com/motty08111213/status/943446161586733056
    def self.status_id_from_url(url)
      if url =~ %r{\Ahttps?://(?:mobile\.)?twitter\.com/(?:i/web|\w+)/status/(\d+)}i
        return $1
      end

      return nil
    end

    def site_name
      "Twitter"
    end

    def image_urls
      if url =~ /(#{ASSET}[^:]+)/
        return [$1 + ":orig" ]
      end

      [url, referer_url].each do |x|
        if x =~ PAGE
          return service.image_urls(api_response)
        end
      end
    end
    memoize :image_urls

    def page_url
      [url, referer_url].each do |x|
        if self.class.status_id_from_url(x).present?
          return x
        end
      end

      return super
    end

    def profile_url
      "https://twitter.com/" + api_response.attrs[:user][:screen_name]
    end

    def artist_name
      api_response.attrs[:user][:screen_name]
    end

    def artist_commentary_title
      ""
    end

    def artist_commentary_desc
      api_response.attrs[:full_text]
    end

    def normalizable_for_artist_finder?
      true
    end

    def normalize_for_artist_finder
      profile_url.downcase
    end

    def tags
      api_response.attrs[:entities][:hashtags].map do |text:, indices:|
        [text, "https://twitter.com/hashtag/#{text}"]
      end
    end
    memoize :tags

    def dtext_artist_commentary_desc
      url_replacements = api_response.urls.map do |obj|
        [obj.url.to_s, obj.expanded_url.to_s]
      end
      url_replacements += api_response.media.map do |obj|
        [obj.url.to_s, ""]
      end
      url_replacements = url_replacements.to_h

      desc = artist_commentary_desc
      desc = CGI::unescapeHTML(desc)
      desc = desc.gsub(%r!https?://t\.co/[^[:space:]]+!i, url_replacements)
      desc = desc.gsub(%r!#([^[:space:]]+)!, '"#\\1":[https://twitter.com/hashtag/\\1]')
      desc = desc.gsub(%r!@([a-zA-Z0-9_]+)!, '"@\\1":[https://twitter.com/\\1]')
      desc.strip
    end
    memoize :dtext_artist_commentary_desc

  public

    def service
      TwitterService.new
    end
    memoize :service

    def api_response
      service.client.status(status_id, tweet_mode: "extended")
    end
    memoize :api_response

    def status_id
      [url, referer_url].map {|x| self.class.status_id_from_url(x)}.compact.first
    end
    memoize :status_id
  end
end
