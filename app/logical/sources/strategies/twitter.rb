module Sources::Strategies
  class Twitter < Base
    PAGE = %r{\Ahttps?://(?:mobile\.)?twitter\.com}i
    PROFILE = %r{\Ahttps?://(?:mobile\.)?twitter.com/(?<username>[a-z0-9_]+)}i

    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg
    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900
    # https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg
    # https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg
    # https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg
    BASE_IMAGE_URL = %r{\Ahttps?://pbs\.twimg\.com/(?<media_type>media|tweet_video_thumb|ext_tw_video_thumb|amplify_video_thumb)}i
    FILENAME1 = /(?<file_name>[a-zA-Z0-9_-]+)\.(?<file_ext>\w+)/i
    FILENAME2 = /(?<file_name>[a-zA-Z0-9_-]+)\?.*format=(?<file_ext>\w+)/i
    FILEPATH1 = %r{(?<file_path>\d+/[\w_-]+/img)}i
    FILEPATH2 = %r{(?<file_path>\d+/img)}i
    IMAGE_URL1 = %r{#{BASE_IMAGE_URL}/#{Regexp.union(FILENAME1, FILENAME2)}}i
    IMAGE_URL2 = %r{#{BASE_IMAGE_URL}/#{Regexp.union(FILEPATH1, FILEPATH2)}/#{FILENAME1}}i

    # Twitter provides a list but it's inaccurate; some names ('intent') aren't
    # included and other names in the list aren't actually reserved.
    # https://developer.twitter.com/en/docs/developer-utilities/configuration/api-reference/get-help-configuration
    RESERVED_USERNAMES = %w[home i intent search]

    # List of hashtag suffixes attached to tag other names
    # Ex: 西住みほ生誕祭2019 should be checked as 西住みほ
    # The regexes will not match if there is nothing preceding
    # the pattern to avoid creating empty strings.
    COMMON_TAG_REGEXES = [
      /(?<!\A)生誕祭(?:\d*)\z/,
      /(?<!\A)誕生祭(?:\d*)\z/,
      /(?<!\A)版もうひとつの深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版深夜のお絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版真剣お絵描き60分一本勝(?:_\d+)?\z/,
      /(?<!\A)版お絵描き60分一本勝負(?:_\d+)?\z/
    ]

    def self.enabled?
      Danbooru.config.twitter_api_key.present? && Danbooru.config.twitter_api_secret.present?
    end

    # https://twitter.com/i/web/status/943446161586733056
    # https://twitter.com/motty08111213/status/943446161586733056
    def self.status_id_from_url(url)
      if url =~ %r{\Ahttps?://(?:(?:www|mobile)\.)?twitter\.com/(?:i/web|\w+)/status/(\d+)}i
        return $1
      end

      nil
    end

    def self.artist_name_from_url(url)
      if url =~ PROFILE && !$~[:username].in?(RESERVED_USERNAMES)
        $~[:username]
      else
        nil
      end
    end

    def domains
      ["twitter.com", "twimg.com"]
    end

    def site_name
      "Twitter"
    end

    def image_urls
      if url =~ IMAGE_URL1
        ["https://pbs.twimg.com/#{$~[:media_type]}/#{$~[:file_name]}.#{$~[:file_ext]}:orig"]
      elsif url =~ IMAGE_URL2
        ["https://pbs.twimg.com/#{$~[:media_type]}/#{$~[:file_path]}/#{$~[:file_name]}.#{$~[:file_ext]}:orig"]
      elsif api_response.present?
        api_response.dig(:extended_entities, :media).to_a.map do |media|
          if media[:type] == "photo"
            media[:media_url_https] + ":orig"
          elsif media[:type].in?(["video", "animated_gif"])
            variants = media.dig(:video_info, :variants)
            videos = variants.select { |variant| variant[:content_type] == "video/mp4" }
            video = videos.max_by { |v| v[:bitrate].to_i }
            video[:url]
          end
        end
      else
        [url]
      end
    end

    def preview_urls
      if api_response.dig(:extended_entities, :media).present?
        api_response.dig(:extended_entities, :media).to_a.map do |media|
          media[:media_url_https] + ":small"
        end
      else
        image_urls.map do |url|
          url.gsub(/:orig\z/, ":small")
        end
      end
    end

    def page_url
      return nil if status_id.blank? || artist_name.blank?
      "https://twitter.com/#{artist_name}/status/#{status_id}"
    end

    def profile_url
      return nil if artist_name.blank?
      "https://twitter.com/#{artist_name}"
    end

    def intent_url
      user_id = api_response.dig(:user, :id_str)
      return nil if user_id.blank?
      "https://twitter.com/intent/user?user_id=#{user_id}"
    end

    def profile_urls
      [profile_url, intent_url].compact
    end

    def artist_name
      if artist_name_from_url.present?
        artist_name_from_url
      elsif api_response.present?
        api_response.dig(:user, :screen_name)
      else
        ""
      end
    end

    def artist_commentary_title
      ""
    end

    def artist_commentary_desc
      api_response[:full_text].to_s
    end

    def normalize_for_artist_finder
      profile_url.try(:downcase).presence || url
    end

    def normalize_for_source
      status_id = self.class.status_id_from_url(url)
      if status_id.present?
        "https://twitter.com/i/web/status/#{status_id}"
      elsif url =~ %r{\Ahttps?://(?:o|image-proxy-origin)\.twimg\.com/\d/proxy\.jpg\?t=(\w+)&}i
        str = Base64.decode64($1)
        source = URI.extract(str, ['http', 'https'])
        if source.any?
          source = source[0]
          if source =~ %r{^https?://twitpic.com/show/large/[a-z0-9]+}i
            source.gsub!(%r{show/large/}, "")
            index = source.rindex('.')
            source = source[0..index - 1]
          end
          source
        end
      end
    end

    def tags
      api_response.dig(:entities, :hashtags).to_a.map do |hashtag|
        [hashtag[:text], "https://twitter.com/hashtag/#{hashtag[:text]}"]
      end
    end

    def normalize_tag(tag)
      COMMON_TAG_REGEXES.each do |rg|
        norm_tag = tag.gsub(rg, "")
        if norm_tag != tag
          return norm_tag
        end
      end
      tag
    end

    def dtext_artist_commentary_desc
      return "" if artist_commentary_desc.blank?

      url_replacements = api_response.dig(:entities, :urls).to_a.map do |obj|
        [obj[:url], obj[:expanded_url]]
      end
      url_replacements += api_response.dig(:extended_entities, :media).to_a.map do |obj|
        [obj[:url], ""]
      end
      url_replacements = url_replacements.to_h

      desc = artist_commentary_desc.unicode_normalize(:nfkc)
      desc = CGI.unescapeHTML(desc)
      desc = desc.gsub(%r{https?://t\.co/[a-zA-Z0-9]+}i, url_replacements)
      desc = desc.gsub(/#([^[:space:]]+)/, '"#\\1":[https://twitter.com/hashtag/\\1]')
      desc = desc.gsub(/@([a-zA-Z0-9_]+)/, '"@\\1":[https://twitter.com/\\1]')
      desc.strip
    end

    def api_client
      TwitterApiClient.new(Danbooru.config.twitter_api_key, Danbooru.config.twitter_api_secret)
    end

    def api_response
      return {} unless self.class.enabled? && status_id.present?
      api_client.status(status_id)
    end

    def status_id
      [url, referer_url].map {|x| self.class.status_id_from_url(x)}.compact.first
    end

    def artist_name_from_url
      [url, referer_url].map {|x| self.class.artist_name_from_url(x)}.compact.first
    end

    memoize :api_response
  end
end
