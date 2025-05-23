# frozen_string_literal: true

class Source::URL::Lofter < Source::URL
  RESERVED_USERNAMES = %w[i uls www]

  attr_reader :username, :user_id, :work_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[lofter.com 127.net lf127.net 126.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0
    # https://imglf3.lf127.net/img/S1d2QlVsWkJhSW1qcnpIS0ZSa3ZJSzFCWFlnUWgzb01DcUdpT1lreG5yQjJVMkhGS09HNGR3PT0.png
    # https://imglf4.lf127.net/img/b7c3e00acd19f7c0/azVib0c4ZHd2WVd6UEhkWG93c1QxRXM3V3VVM2pab0pqaXB3UFV4WG1tVT0.png?imageView&thumbnail=1680x0&quality=96&stripmeta=0
    # http://imglf0.nosdn.127.net/img/cHl3bXNZdDRaaHBnNWJuN1Y4OXBqR01CeVBZSVNmU2FWZWtHc1h4ZTZiUGxlRzMwZnFDM1JnPT0.jpg (404)
    in _, ("127.net" | "lf127.net"), "img", *rest
      @full_image_url = without(:query).to_s

    # https://vodm2lzexwq.vod.126.net/vodm2lzexwq/Pc5jg1nL_3039990631_sd.mp4?resId=254486990bfa2cd7aa860229db639341_3039990631_1&sign=4j02HTHXqNfhaF%2B%2FO14Ny%2F9SMNZj%2FIjpJDCqXfYa4aM%3D
    in _, "126.net", *rest
      @full_image_url = original_url

    # https://www.lofter.com/front/blog/home-page/noshiqian
    in _, "lofter.com", "front", "blog", "home-page", username
      @username = username

    # http://www.lofter.com/app/xiaokonggedmx
    # http://www.lofter.com/blog/semblance
    in _, "lofter.com", ("app" | "blog"), username
      @username = username

    # https://www.lofter.com/mentionredirect.do?blogId=1278105311
    in _, "lofter.com", "mentionredirect.do" if params[:blogId].present?
      @user_id = params[:blogId]

    # https://gengar563.lofter.com/post/1e82da8c_1c98dae1b
    # https://gengar563.lofter.com/front/post/1e82da8c_1c98dae1b
    in username, "lofter.com", *, "post", work_id unless username.in?(RESERVED_USERNAMES)
      @username = username
      @work_id = work_id

    # http://gengar563.lofter.com
    # http://gengar563.lofter.com/view
    in username, "lofter.com", *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://uls.lofter.com/?h5url=https%3A%2F%2Flesegeng.lofter.com%2Fpost%2F1f0aec07_2bbc5ce0b
    in "uls", "lofter.com", *rest if params[:h5url].present?
      url = Source::URL.parse(params[:h5url])
      @username = url.try(:username)
      @work_id = url.try(:work_id)

    # https://www.lofter.com/tag/初音ミク
    else
      nil
    end
  end

  def image_url?
    url.domain.in?(%w[lf127.net 127.net 126.net])
  end

  def page_url
    "https://#{username}.lofter.com/post/#{work_id}" if username.present? && work_id.present?
  end

  def profile_url
    if username.present?
      "https://#{username}.lofter.com"
    elsif user_id.present?
      "https://www.lofter.com/mentionredirect.do?blogId=#{user_id}"
    end
  end

  def secondary_url?
    profile_url? && user_id.present?
  end
end
