# frozen_string_literal: true

# @see Source::Extractor::Douyin
class Source::URL::Douyin < Source::URL
  site "Douyin" do
    url "https://www.douyin.com"
    domains %w[douyin.com iesdouyin.com douyinpic.com]

    credential :uifid, default: Danbooru.config.douyin_uifid, help: %{Your Douyin `UIFID` cookie. Logging in isn't required.}
    credential :ttwid, default: Danbooru.config.douyin_ttwid, help: %{Your Douyin `ttwid` cookie. Logging in isn't required.}
    credential :s_v_web_id, default: Danbooru.config.douyin_s_v_web_id, help: %{Your Douyin `s_v_web_id` cookie.  Logging in isn't required.}
  end

  extractors { [Source::Extractor::Douyin, Source::Extractor::URLShortener] }

  attr_reader :post_id, :post_type, :sec_uid, :redirect_id

  def self.match?(url)
    url.domain.in?(%w[douyin.com iesdouyin.com douyinpic.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://p3-pc-sign.douyinpic.com/tos-cn-i-0813c000-ce/oUlDIBeDAGIBMAAAGeSKeL04aTgHBQnI2fgCvA~noop.jpeg?biz_tag=pcweb_cover&from=327834062&lk3s=138a59ce&s=PackSourceEnum_PUBLISH&se=false&x-expires=1794412800&x-signature=%2B%2BOarl8Jm0TbA4x4ArqwYBIJ5z8%3D
    #
    # Image URLs are signed and expire.
    in _, "douyinpic.com", *rest
      nil

    # https://www.douyin.com/aweme/v1/play/?video_id=v1e00fgi0000d1mfe5vog65vhen11m4g&line=0&file_id=c91511bc740e4ffb9e77e92f50164e1f&sign=26f6b5b6d115ff53471a76094882d490&is_play_url=1&source=PackSourceEnum_AWEME_DETAIL&biz_sign=NRPI1l
    in _, "douyin.com", "aweme", "v1", "play"
      @video_url = true

    # https://www.douyin.com/video/7127940372856114467
    # https://www.douyin.com/note/7698000683710743973
    in _, "douyin.com", ("video" | "note") => post_type, /\A\d+\z/ => post_id
      @post_type = post_type
      @post_id = post_id

    # https://www.iesdouyin.com/share/video/7524660855435988284/?region=CN&mid=7524660840075660073&u_code=1b5gh7ddk6j8
    # https://www.iesdouyin.com/share/note/7698000683710743973/
    in _, "iesdouyin.com", "share", ("video" | "note") => post_type, /\A\d+\z/ => post_id
      @post_type = post_type
      @post_id = post_id

    # https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98?modal_id=7127940372856114467
    # https://www.douyin.com/user/MS4wLjABAAAAEKnfa654JAJ_N5lgZDQluwsxmY0lhfmEYNQBBkwGG98
    in _, "douyin.com", "user", /\AMS4w[\w-]+\z/ => sec_uid
      @sec_uid = sec_uid
      @post_id = params[:modal_id] if params[:modal_id].to_s.match?(/\A\d+\z/)

    # https://www.douyin.com/discover?modal_id=7127940372856114467
    # https://www.douyin.com/jingxuan?modal_id=7127940372856114467
    in _, "douyin.com", *rest if params[:modal_id].to_s.match?(/\A\d+\z/)
      @post_id = params[:modal_id]

    # https://v.douyin.com/znwIiWQwdiU/
    # => https://www.iesdouyin.com/share/video/7524660855435988284/?region=CN&...
    in "v", "douyin.com", /\A[a-zA-Z0-9]+\z/ => redirect_id
      @redirect_id = redirect_id

    else
      nil
    end
  end

  def video_url?
    @video_url.present?
  end

  def image_url?
    video_url? || domain == "douyinpic.com" || super
  end

  def extractor_class
    redirect_id.present? ? Source::Extractor::URLShortener : Source::Extractor::Douyin
  end

  def page_url
    if post_type == "note"
      "https://www.douyin.com/note/#{post_id}"
    elsif post_id.present?
      "https://www.douyin.com/video/#{post_id}"
    end
  end

  def profile_url
    "https://www.douyin.com/user/#{sec_uid}" if sec_uid.present?
  end
end
