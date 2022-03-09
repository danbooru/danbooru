# frozen_string_literal: true

# Unhandled:
#
# Video URLs:
#
# * https://video.twimg.com/tweet_video/E_8lAMJUYAIyenr.mp4
# * https://video.twimg.com/ext_tw_video/1496554514312269828/pu/pl/Srzcr2EsBK5Mwlvf.m3u8?tag=12&container=fmp4
# * https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/360x270/SygSrUcDpCr1AnOf.mp4?tag=12
# * https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/960x720/wiC1XIw8QehhL5JL.mp4?tag=12
# * https://video.twimg.com/ext_tw_video/1496554514312269828/pu/vid/480x360/amWjOw0MmLdnPMPB.mp4?tag=12
#
# Profile image URLs:
#
# * https://pbs.twimg.com/profile_banners/780804311529906176/1475001696
# * https://pbs.twimg.com/profile_images/1493345400929112064/lF1mY1i2_normal.jpg
#
# Shortened URLs:
#
# * https://t.co/Dxn7CuVErW => https://twitter.com/Kekeflipnote/status/1496555599718498319/video/1
# * https://pic.twitter.com/Dxn7CuVErW => https://twitter.com/Kekeflipnote/status/1496555599718498319/video/1

class Source::URL::Twitter < Source::URL
  # Twitter provides a list of reserved usernames but it's inaccurate; some names ('intent') aren't
  # included and other names in the list aren't actually reserved.
  # https://developer.twitter.com/en/docs/developer-utilities/configuration/api-reference/get-help-configuration
  RESERVED_USERNAMES = %w[home i intent search]

  attr_reader :status_id, :twitter_username

  def self.match?(url)
    url.host.in?(%w[twitter.com mobile.twitter.com pic.twitter.com pbs.twimg.com video.twimg.com t.co])
  end

  def parse
    case [domain, *path_segments]

    # https://twitter.com/i/web/status/943446161586733056
    in "twitter.com", "i", "web", "status", status_id
      @status_id = status_id

    # https://twitter.com/motty08111213/status/943446161586733056
    # https://twitter.com/motty08111213/status/943446161586733056?s=19
    # https://twitter.com/Kekeflipnote/status/1496555599718498319/video/1
    # https://twitter.com/sato_1_11/status/1496489742791475201/photo/2
    in "twitter.com", username, "status", status_id, *rest
      @twitter_username = username
      @status_id = status_id

    # https://twitter.com/motty08111213
    in "twitter.com", username, *rest
      @twitter_username = username unless username.in?(RESERVED_USERNAMES)

    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg
    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:small
    # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb?format=jpg&name=900x900
    #
    # video thumbnail urls:
    # https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg
    # https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg
    # https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg
    in "twimg.com", ("media" | "tweet_video_thumb" | "ext_tw_video_thumb" | "amplify_video_thumb") => media_type, *subdirs, file
      # EBGbJe_U8AA4Ekb.jpg:small
      @file, @file_size = file.split(":")
      @file, @file_ext = @file.split(".")

      # EBGbJe_U8AA4Ekb?format=jpg&name=900x900
      @file_size = params[:name] if params[:name].present?
      @file_ext = params[:format] if params[:format].present?

      # /media/EBGbJe_U8AA4Ekb.jpg
      # /ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg
      @file_path = File.join(media_type, subdirs.join("/"), "#{@file}.#{@file_ext}")
    else
    end
  end

  def image_url?
    orig_image_url.present?
  end

  # https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig
  # https://pbs.twimg.com/tweet_video_thumb/ETkN_L3X0AMy1aT.jpg:orig
  # https://pbs.twimg.com/ext_tw_video_thumb/1243725361986375680/pu/img/JDA7g7lcw7wK-PIv.jpg:orig
  # https://pbs.twimg.com/amplify_video_thumb/1215590775364259840/img/lolCkEEioFZTb5dl.jpg:orig
  def orig_image_url
    return nil unless @file_path.present?
    "#{site}/#{@file_path}:orig"
  end
end
