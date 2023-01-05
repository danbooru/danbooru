# frozen_string_literal: true

# @see Source::URL::Twitter
class Source::Extractor
  class Twitter < Source::Extractor
    # List of hashtag suffixes attached to tag other names
    # Ex: 西住みほ生誕祭2019 should be checked as 西住みほ
    # The regexes will not match if there is nothing preceding
    # the pattern to avoid creating empty strings.
    COMMON_TAG_REGEXES = [
      /(?<!\A)生誕祭(?:\d*)\z/,
      /(?<!\A)誕生祭(?:\d*)\z/,
      /(?<!\A)版もうひとつの深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版深夜の真剣お絵かき60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)深夜の真剣お絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版深夜のお絵描き60分一本勝負(?:_\d+)?\z/,
      /(?<!\A)版真剣お絵描き60分一本勝(?:_\d+)?\z/,
      /(?<!\A)版お絵描き60分一本勝負(?:_\d+)?\z/
    ]

    def self.enabled?
      Danbooru.config.twitter_api_key.present? && Danbooru.config.twitter_api_secret.present?
    end

    def match?
      Source::URL::Twitter === parsed_url
    end

    def image_urls
      # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig
      if parsed_url.image_url?
        [parsed_url.full_image_url]
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
        []
      end
    end

    def page_url
      return nil if status_id.blank? || tag_name.blank?
      "https://twitter.com/#{tag_name}/status/#{status_id}"
    end

    def profile_url
      return nil if tag_name.blank?
      "https://twitter.com/#{tag_name}"
    end

    def intent_url
      return nil if user_id.blank?
      "https://twitter.com/intent/user?user_id=#{user_id}"
    end

    def profile_urls
      [profile_url, intent_url].compact.uniq
    end

    def user_id
      parsed_url.user_id || parsed_referer&.user_id || api_response.dig(:user, :id_str)
    end

    def tag_name
      if tag_name_from_url.present?
        tag_name_from_url
      elsif api_response.present?
        api_response.dig(:user, :screen_name)
      end
    end

    def artist_name
      if api_response.present?
        api_response.dig(:user, :name)
      else
        tag_name
      end
    end

    def artist_commentary_title
      ""
    end

    def artist_commentary_desc
      api_response[:full_text].to_s
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
      return nil if artist_commentary_desc.blank?

      dtext = "".dup
      desc = artist_commentary_desc
      entities = []

      entities += api_response.dig(:entities, :hashtags).to_a.pluck(:indices, :text).map do |e|
        { first: e[0][0], last: e[0][1], text: e[1], dtext: %Q("##{e[1]}":[https://twitter.com/hashtag/#{Danbooru::URL.escape(e[1])}]) }
      end

      entities += api_response.dig(:entities, :urls).to_a.pluck(:indices, :expanded_url).map do |e|
        { first: e[0][0], last: e[0][1], text: e[1], dtext: "<#{e[1]}>" }
      end

      entities += api_response.dig(:entities, :user_mentions).to_a.pluck(:indices, :screen_name).map do |e|
        { first: e[0][0], last: e[0][1], text: e[1], dtext: %Q("@#{e[1]}":[https://twitter.com/#{CGI.escape(e[1])}]) }
      end

      entities += api_response.dig(:entities, :symbols).to_a.pluck(:indices, :text).map do |e|
        { first: e[0][0], last: e[0][1], text: e[1], dtext: %Q("$#{e[1]}":[https://twitter.com/search?q=$#{CGI.escape(e[1])}]) }
      end

      entities += api_response.dig(:extended_entities, :media).to_a.pluck(:indices, :expanded_url).map do |e|
        { first: e[0][0], last: e[0][1], text: e[1], dtext: "" }
      end

      entities.sort_by! { _1[:first] }

      i = 0
      entities.each do |entity|
        dtext << desc[i..entity[:first]-1] if i < entity[:first]
        dtext << entity[:dtext]
        i = entity[:last]
      end

      dtext << desc[i..desc.size]
      dtext = CGI.unescapeHTML(dtext).strip
      dtext
    end

    def api_client
      TwitterApiClient.new(Danbooru.config.twitter_api_key, Danbooru.config.twitter_api_secret, http: http)
    end

    def api_response
      return {} unless self.class.enabled? && status_id.present?
      api_client.status(status_id)
    end

    def status_id
      parsed_url.status_id || parsed_referer&.status_id
    end

    def tag_name_from_url
      parsed_url.username || parsed_referer&.username
    end

    memoize :api_response
  end
end
