# frozen_string_literal: true

class Source::URL::ArcaLive < Source::URL
  attr_reader :full_image_url, :channel, :post_id, :username, :user_id

  def self.match?(url)
    url.domain.in?(%w[arca.live namu.la])
  end

  def site_name
    "Arca.live"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg
    # https://ac2.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig
    # https://ac2-o.namu.la/20221225sac2/e06dcf8edd29c597240898a6752c74dbdd0680fc932cfd0ecc898795f1db34b5.jpg?type=orig
    # https://ac.namu.la/20221211sac/5ea7fbca5e49ec16beb099fc6fc991690d37552e599b1de8462533908346241e.png (actually .webp)
    # https://ac-o.namu.la/20221211sac/7f73beefc4f18a2f986bc4c6821caba706e27f4c94cb828fc16e2af1253402d9.gif?type=orig
    # https://ac.namu.la/20221211sac/7f73beefc4f18a2f986bc4c6821caba706e27f4c94cb828fc16e2af1253402d9.mp4 (.gif sample)
    in _, "namu.la", date, /\A\h{64}/
      if file_ext == "mp4"
        @full_image_url = "#{site}/#{date}/#{filename}.gif?type=orig"
      else
        @full_image_url = "#{site}/#{date}/#{filename}.#{file_ext}?type=orig"
      end

    # https://arca.live/b/arknights/66031722
    in _, "arca.live", "b", channel, post_id
      @channel = channel
      @post_id = post_id

    # https://arca.live/u/@Nauju/45320365
    in _, "arca.live", "u", /\A@/ => username, /\A\d+\z/ => user_id
      @username = username.delete_prefix("@")
      @user_id = user_id

    # https://arca.live/u/@Si리링
    in _, "arca.live", "u", /\A@/ => username
      @username = username.delete_prefix("@")

    else
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    "https://arca.live/b/#{channel}/#{post_id}" if channel.present? && post_id.present?
  end

  def profile_url
    if username.present? && user_id.present?
      "https://arca.live/u/@#{username}/#{user_id}"
    elsif username.present?
      "https://arca.live/u/@#{username}"
    end
  end
end
