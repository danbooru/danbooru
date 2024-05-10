# frozen_string_literal: true

# @see Source::URL::Google
# @see Source::Extractor::Youtube
class Source::URL::Youtube < Source::URL
  RESERVED_NAMES = %w[about account ads c channel creators feed gaming learn new playables playlist podcasts post premium results shorts t user vi watch]

  attr_reader :username, :handle, :channel_name, :channel_id, :bare_id, :video_id, :post_id, :playlist_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[youtube.com youtu.be ytimg.com]) || ([url.subdomain, url.domain] in /yt/, ("ggpht.com" | "googleusercontent.com"))
  end

  def parse
    case [subdomain, domain, *path_segments]

    # Note that lh*.ggpht.com image URLs are handled by Source::URL::Google instead because they're not only used for Youtube.
    #
    # https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=s1600-rw-nd-v1
    # https://yt3.ggpht.com/a/AATXAJw4dDQ19NyBDauQOSCTypEdS8pGleIVH81mo_Xj=s900-c-k-c0xffffffff-no-rj-mo
    # https://yt3.ggpht.com/a-/AAuE7mA3PVjbd2Cq5Nixkf7WCC1vAdf_e4KOk7P45w=s100-mo-c-c0xffffffff-rj-k-no
    # https://yt3.googleusercontent.com/5eDKuCEpw0-fZVUX29AF7XCAQY7t3FeocoiBrmQd1PGQemBcCQZlkqazoDwSvR7mbEc_IiRgNko=w1707-fcrop64=1,00005a57ffffa5a8-k-c0xffffffff-no-nd-rj (channel banner)
    in /^yt\d+$/, ("ggpht.com" | "googleusercontent.com"), *subdirs, image_id
      image_id = image_id.split("=").first
      @full_image_url = ["https://#{host}", *subdirs, "#{image_id}=d"].join("/")

    # https://www.youtube.com/@nonomaRui
    in _, "youtube.com", /^@/ => handle, *rest
      @handle = handle.delete_prefix("@")

    # https://www.youtube.com/user/SiplickIshida
    in _, "youtube.com", "user", username, *rest
      @username = username

    # https://www.youtube.com/c/ruichnonomarui
    in _, "youtube.com", "c", channel_name, *rest
      @channel_name = channel_name

    # https://www.youtube.com/channel/UCfrCa2Y6VulwHD3eNd3HBRA
    # https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw/community?lb=UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf
    in _, "youtube.com", "channel", channel_id, *rest
      @channel_id = channel_id
      @post_id = params[:lb]

    # https://www.youtube.com/watch?v=dQw4w9WgXcQ
    in _, "youtube.com", "watch"
      @video_id = params[:v]

    # https://www.youtube.com/shorts/GSR2ghvoTDY
    in _, "youtube.com", "shorts", video_id
      @video_id = video_id

    # https://www.youtube.com/embed/dQw4w9WgXcQ?si=Ui3IIE9NqhdTgJMx
    in _, "youtube.com", "embed", video_id
      @video_id = video_id

    # https://youtu.be/dQw4w9WgXcQ?si=i9hAbs3VV0ewqq6F
    in _, "youtu.be", video_id
      @video_id = video_id

    # https://www.youtube.com/post/UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf (redirects to https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw/community?lb=UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf)
    in _, "youtube.com", "post", post_id
      @post_id = post_id

    # https://www.youtube.com/playlist?list=OLAK5uy_noU123lqMHztLaZkpu00qEBr0thoaq1c4
    # https://music.youtube.com/playlist?list=OLAK5uy_noU123lqMHztLaZkpu00qEBr0thoaq1c4
    in _, "youtube.com", "playlist"
      @playlist_id = params[:list]

    # https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg (video thumbnail)
    in "img", "youtube.com", "vi", video_id, _
      @video_id = video_id

    # https://i.ytimg.com/vi/rZBBygITzyw/maxresdefault.jpg
    # http://i.ytimg.com/vi/kltbyO3QXo0/hqdefault.jpg
    # https://i.ytimg.com/vi/Db6MfrB7FZk/hq720.jpg?sqp=-oaymwEjCOgCEMoBSFryq4qpAxUIARUAAAAAGAElAADIQj0AgKJDeAE=&rs=AOn4CLBtaSbqvqTq7F7lmqKZ-yHMjldMqw
    in _, "ytimg.com", "vi", video_id, _
      @video_id = video_id

    # https://www.youtube.com/ruichnonomarui (channel name: https://www.youtube.com/c/ruichnonomarui)
    # https://www.youtube.com/SiplickIshida (username: https://www.youtube.com/user/SiplickIshida)
    # https://www.youtube.com/SerafleurArt (handle: https://www.youtube.com/@SerafleurArt)
    in _, "youtube.com", bare_id unless bare_id.in?(RESERVED_NAMES)
      @bare_id = bare_id

    # http://i3.ytimg.com/bg/2w3KRCTGcETCq9JxPZ7RVQ/default.jpg?app=bg&v=5c97c0
    # http://i2.ytimg.com/bg/eE1WPqZHyo9W-au7tJkkog/default.jpg?app=bg&v=596708
    else
      nil
    end
  end

  def image_url?
    domain == "ggpht.com" || super
  end

  def page_url
    if video_id.present?
      "https://www.youtube.com/watch?v=#{video_id}"
    elsif playlist_id.present?
      # These are treated as page URLs for the purpose of having a page URL for album covers.
      "https://music.youtube.com/playlist?list=#{playlist_id}"
    elsif post_id.present?
      "https://www.youtube.com/post/#{post_id}"
    end
  end

  def profile_url
    # Handles, usernames, and channel names are all different things and are not interchangeable.
    if handle.present?
      "https://www.youtube.com/@#{handle}"
    elsif username.present?
      "https://www.youtube.com/user/#{username}"
    elsif channel_name.present?
      "https://www.youtube.com/c/#{channel_name}"
    elsif channel_id.present?
      "https://www.youtube.com/channel/#{channel_id}"
    elsif bare_id.present?
      "https://www.youtube.com/#{bare_id}"
    end
  end
end
