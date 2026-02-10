# frozen_string_literal: true

# Profile image URLs:
# * https://pbs.twimg.com/profile_images/1493345400929112064/lF1mY1i2_normal.jpg

class Source::URL::Twitter < Source::URL
  # Twitter provides a list of reserved usernames but it's inaccurate; some names ('intent') aren't
  # included and other names in the list aren't actually reserved.
  # https://developer.twitter.com/en/docs/developer-utilities/configuration/api-reference/get-help-configuration
  RESERVED_USERNAMES = %w[home explore i intent messages notifications privacy search tos]

  # fxtwitter.com, etc are from https://github.com/FixTweet/FxTwitter, a proxy for better embedding
  # nitter.net, xcancel etc are from https://github.com/zedeus/nitter, a privacy-focused frontend
  TWITTER_PROXY_DOMAINS = %w[fxtwitter.com vxtwitter.com twittpr.com fixvx.com fixupx.com nitter.net xcancel.com]
  TWITTER_PROXY_HOSTS = %w[nitter.poast.org nitter.privacydev.net]

  # Unix time in milliseconds that must be added to the snowflake ID's timestamp.
  TWITTER_EPOCH = 1_288_834_974_657 # 2010-11-04T01:42:54.657000Z

  attr_reader :status_id, :username, :user_id, :full_image_url, :base10_snowflake_id, :base64_snowflake_id, :timestamp

  def self.match?(url)
    # https://o.twimg.com URLs are handled by Source::URL::TwitPic.
    # https://pic.twitter.com and https://t.co URLs are handled by Source::URL::URLShortener.
    (url.domain.in?(%w[twitter.com twimg.com x.com]) && !url.host.in?(%w[o.twimg.com pic.twitter.com pic.x.com])) || is_twitter_proxy?(url)
  end

  def self.is_twitter_proxy?(url)
    url.domain.in?(TWITTER_PROXY_DOMAINS) || url.host.in?(TWITTER_PROXY_HOSTS)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg
    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:small
    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900
    #
    # video thumbnail urls:
    # https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg
    # https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg
    # https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg
    in "pbs", "twimg.com", ("media" | "tweet_video_thumb" | "ext_tw_video_thumb" | "amplify_video_thumb") => media_type, *subdirs, file
      # EBGbJe_U8AA4Ekb.jpg:small
      @file, @file_size = file.split(":")
      @file, @file_ext = @file.split(".")

      # EBGbJe_U8AA4Ekb?format=jpg&name=900x900
      @file_size = params[:name] if params[:name].present?
      @file_ext = params[:format] if params[:format].present?

      # /media/EBGbJe_U8AA4Ekb.jpg
      # /ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg
      @full_image_url = File.join(site, media_type, *subdirs, "#{@file}.#{@file_ext}:orig")
      @image_sample = @file_size != "orig"

      if media_type.in?(["media", "tweet_video_thumb"])
        @base64_snowflake_id = filename
      elsif subdirs.first =~ /^(\d+)$/
        @base10_snowflake_id = $1
      end

    # https://pbs.twimg.com/profile_banners/780804311529906176/1475001696
    # https://pbs.twimg.com/profile_banners/780804311529906176/1475001696/600x200
    in "pbs", "twimg.com", "profile_banners" => media_type, /^\d+$/ => user_id, /^\d+$/ => file_id, *dimensions
      @user_id = user_id
      @profile_banner = true
      @file_size, = dimensions
      @full_image_url = "#{site}/#{media_type}/#{user_id}/#{file_id}/1500x500"
      @image_sample = @file_size != "1500x500"
      @timestamp = file_id

    # https://pbs.twimg.com/profile_images/1425792004877733891/UM8s9d2x_400x400.png (sample)
    # https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_normal.jpeg (sample)
    # https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs_400x400.jpeg (sample)
    # https://pbs.twimg.com/profile_images/417182061145780225/ttN6_CSs.jpeg (full; 1252x1252)
    # https://pbs.twimg.com/profile_images/378800000094437961/99ac06f2873f8597fa5961a404769066.gif (obsolete)
    in "pbs", "twimg.com", "profile_images", /^\d+$/ => media_id, /^(\w{8})(_\w+)?\.(\w+)$/
      @file = $1
      @file_size = $2
      @file_ext = $3
      @full_image_url = "https://pbs.twimg.com/profile_images/#{media_id}/#{$1}.#{file_ext}"
      @image_sample = @file_size.present?
      @base10_snowflake_id = media_id

    # https://pbs.twimg.com/ad_img/1415875929608396801/pklSzcPz?format=jpg&name=small
    in "pbs", "twimg.com", "ad_img" => media_type, /^\d+$/ => media_id, file if params[:format].present?
      @file_size = params[:name] if params[:name].present?
      @full_image_url = "#{site}/#{media_type}/#{media_id}/#{file}?format=#{params[:format]}&name=orig"
      @image_sample = @file_size != "orig"
      @base10_snowflake_id = media_id

    # https://video.twimg.com/tweet_video/E_8lAMJUYAIyenr.mp4
    in "video", "twimg.com", "tweet_video" => media_type, file
      @base64_snowflake_id = filename

    # https://video.twimg.com/ext_tw_video/1496554514312269828/pu/pl/Srzcr2EsBK5Mwlvf.m3u8?tag=12&container=fmp4
    # https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/360x270/SygSrUcDpCr1AnOf.mp4?tag=12
    # https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/960x720/wiC1XIw8QehhL5JL.mp4?tag=12
    # https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/480x360/amWjOw0MmLdnPMPB.mp4?tag=12
    # https://video.twimg.com/amplify_video/1215590775364259840/vid/1280x720/wE6Ngd7-JPw5vCZP.mp4?tag=13
    in "video", "twimg.com", ("ext_tw_video" | "amplify_video") => media_type, /^\d+$/ => media_id, *subdirs, file
      @base10_snowflake_id = media_id

    # https://si0.twimg.com/profile_background_images/378800000179574457/3UC-Xcnj.jpeg (obsolete)
    in "si0", "twimg.com", "profile_background_images" => media_type, /^\d+$/ => media_id, file
      @base10_snowflake_id = media_id

    # https://pbs-0.twimg.com/media/C9xkZf7UMAEbsf7.jpg (obsolete)
    in "pbs-0", "twimg.com", "media" => media_type, file
      @base64_snowflake_id = file

    # https://si0.twimg.com/profile_images/2375708513/luajz7c7uredbbp4v9kr.jpeg (obsolete)
    # https://a2.twimg.com/profile_images/1210943186/KABABABABA.jpg (obsolete)
    in _, "twimg.com", *rest
      nil

    # https://x.com/i/web/status/943446161586733056
    in _, _, "i", "web", "status", status_id
      @status_id = status_id
      @base10_snowflake_id = status_id

    # https://x.com/i/status/943446161586733056
    # https://x.com/motty08111213/status/943446161586733056
    # https://x.com/@motty08111213/status/943446161586733056
    # https://x.com/motty08111213/status/943446161586733056?s=19
    # https://x.com/Kekeflipnote/status/1496555599718498319/video/1
    # https://x.com/sato_1_11/status/1496489742791475201/photo/2
    # https://fxtwitter.com/example/status/1548117889437208581.jpg
    in _, _, username, ("status" | "statuses"), status_id, *rest
      username = username.delete_prefix("@")
      @username = username unless username.in?(RESERVED_USERNAMES)
      @status_id = status_id.split(".").first
      @base10_snowflake_id = status_id

    # https://x.com/intent/user?user_id=1485229827984531457
    in _, _, "intent", "user" if params[:user_id].present?
      @user_id = params[:user_id]

    # https://x.com/intent/user?screen_name=ryuudog_NFT
    in _, _, "intent", "user" if params[:screen_name].present?
      @username = params[:screen_name]

    # https://x.com/i/user/889592953
    in _, _, "i", "user", user_id
      @user_id = user_id

    # https://x.com/merry_bongbong/header_photo
    in _, _, username, "header_photo" unless username.in?(RESERVED_USERNAMES)
      @profile_banner = true
      @username = username.delete_prefix("@")

    # https://x.com/motty08111213
    # https://x.com/motty08111213/likes
    # https://x.com/@eemapso
    in _, _, username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username.delete_prefix("@")

    else
      nil
    end
  end

  def profile_banner?
    @profile_banner == true
  end

  def image_url?
    domain == "twimg.com"
  end

  def bad_link?
    image_url? && !profile_banner?
  end

  def image_sample?
    @image_sample
  end

  def page_url
    if username.present? && status_id.present?
      "https://x.com/#{username}/status/#{status_id}"
    elsif status_id.present?
      "https://x.com/i/web/status/#{status_id}"
    elsif profile_banner? && username.present?
      "https://x.com/#{username}/header_photo"
    end
  end

  def profile_url
    if username.present?
      "https://x.com/#{username}"
    elsif user_id.present?
      "https://x.com/i/user/#{user_id}"
    end
  end

  def parsed_date
    if base10_snowflake_id
      self.class.parse_time_from_snowflake_id(base10_snowflake_id.to_i)
    elsif base64_snowflake_id
      snowflake_id = Base64.decode64(base64_snowflake_id).unpack1("Q>")
      self.class.parse_time_from_snowflake_id(snowflake_id)
    elsif timestamp
      Time.at(timestamp.to_i).utc
    end
  end

  def self.parse_time_from_snowflake_id(snowflake_id)
    # The status IDs and media IDs are "snowflakes" that contains the creation timestamp.
    # https://en.wikipedia.org/wiki/Snowflake_ID
    # https://github.com/twitter-archive/snowflake/blob/snowflake-2010/src/main/scala/com/twitter/service/snowflake/IdWorker.scala
    # For status IDs this timestamp is when the tweet was published.
    # For media IDs this is when the media was uploaded.
    return nil unless snowflake_id.present?
    return nil if snowflake_id < 300_000_000_000_000 # Until 2010-11-04 status IDs were sequential, not snowflakes.
    unix_time = (snowflake_id >> 22) + TWITTER_EPOCH
    Danbooru::Helpers.time_from_ms_since_epoch(unix_time)
  end
end
