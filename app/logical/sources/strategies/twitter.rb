module Sources::Strategies
  class Twitter < Base
    PAGE = %r!\Ahttps?://(?:mobile\.)?twitter\.com!i
    ASSET = %r!\A(https?://(?:video|pbs)\.twimg\.com/media/)!i
    PROFILE = %r!\Ahttps?://(?:mobile\.)?twitter.com/(?<username>[a-z0-9_]+)!i

    # Twitter provides a list but it's inaccurate; some names ('intent') aren't
    # included and other names in the list aren't actually reserved.
    # https://developer.twitter.com/en/docs/developer-utilities/configuration/api-reference/get-help-configuration
    RESERVED_USERNAMES = %w[home i intent search]

    def self.match?(*urls)
      urls.compact.any? { |x| x =~ PAGE || x =~ ASSET}
    end

    def self.enabled?
      TwitterService.new.enabled?
    end

    # https://twitter.com/i/web/status/943446161586733056
    # https://twitter.com/motty08111213/status/943446161586733056
    def self.status_id_from_url(url)
      if url =~ %r{\Ahttps?://(?:mobile\.)?twitter\.com/(?:i/web|\w+)/status/(\d+)}i
        return $1
      end

      return nil
    end

    def self.artist_name_from_url(url)
      if url =~ PROFILE && !$~[:username].in?(RESERVED_USERNAMES)
        $~[:username]
      else
        nil
      end
    end

    def site_name
      "Twitter"
    end

    def image_urls
      if url =~ /(#{ASSET}[^:]+)/
        return [$1 + ":orig" ]
      elsif api_response.blank?
        return [url]
      end

      [url, referer_url].each do |x|
        if x =~ PAGE
          return service.image_urls(api_response)
        end
      end
    end
    memoize :image_urls

    def preview_urls
      image_urls.map do |x|
        x.sub(%r!\.(jpg|jpeg|png|gif)(?::orig)?\z!i, '.\1:small')
      end
    end

    def page_url
      return "" if status_id.blank? || artist_name.blank?
      "https://twitter.com/#{artist_name}/status/#{status_id}"
    end

    def profile_url
      return "" if artist_name.blank?
      "https://twitter.com/#{artist_name}"
    end

    def artist_name
      if artist_name_from_url.present?
        artist_name_from_url
      elsif api_response.present?
        api_response.attrs[:user][:screen_name]
      else
        ""
      end
    end

    def artist_commentary_title
      ""
    end

    def artist_commentary_desc
      return "" if api_response.blank?
      api_response.attrs[:full_text]
    end

    def normalizable_for_artist_finder?
      url =~ PAGE
    end

    def normalize_for_artist_finder
      profile_url.try(:downcase).presence || url
    end

    def tags
      return [] if api_response.blank?

      api_response.attrs[:entities][:hashtags].map do |text:, indices:|
        [text, "https://twitter.com/hashtag/#{text}"]
      end
    end
    memoize :tags

    def dtext_artist_commentary_desc
      return "" if artist_commentary_desc.blank?

      url_replacements = api_response.urls.map do |obj|
        [obj.url.to_s, obj.expanded_url.to_s]
      end
      url_replacements += api_response.media.map do |obj|
        [obj.url.to_s, ""]
      end
      url_replacements = url_replacements.to_h

      desc = artist_commentary_desc.unicode_normalize(:nfkc)
      desc = CGI::unescapeHTML(desc)
      desc = desc.gsub(%r!https?://t\.co/[a-zA-Z0-9]+!i, url_replacements)
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
      return {} if !service.enabled?
      service.status(status_id, tweet_mode: "extended")
    rescue ::Twitter::Error::NotFound
      {}
    end
    memoize :api_response

    def status_id
      [url, referer_url].map {|x| self.class.status_id_from_url(x)}.compact.first
    end
    memoize :status_id

    def artist_name_from_url
      [url, referer_url].map {|x| self.class.artist_name_from_url(x)}.compact.first
    end
  end
end
