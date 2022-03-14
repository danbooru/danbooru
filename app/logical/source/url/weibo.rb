# frozen_string_literal: true

# Unhandled:
#
# http://t.cn/A6c3ZAE1 -> https://m.weibo.cn/status/4623322346685004

class Source::URL::Weibo < Source::URL
  attr_reader :full_image_url, :artist_short_id, :artist_long_id, :username

  def self.match?(url)
    url.domain.in?(["weibo.com", "weibo.cn", "sinaimg.cn"])
  end

  def parse
    case [host, *path_segments]

    # http://ww1.sinaimg.cn/large/69917555gw1f6ggdghk28j20c87lbhdt.jpg
    # https://wx1.sinaimg.cn/large/002NQ2vhly1gqzqfk1agfj62981aw4qr02.jpg
    # http://ww4.sinaimg.cn/mw690/77a2d531gw1f4u411ws3aj20m816fagg.jpg (sample)
    # https://wx4.sinaimg.cn/orj360/e3930166gy1g546bz86cij20u00u040y.jpg (sample)
    # http://ww3.sinaimg.cn/mw1024/0065kjmOgw1fabcanrzx6j30f00lcjwv.jpg (sample)
    # https://wx1.sinaimg.cn/original/7004ec1cly1ge9dcbsw4lj20jg2ir7wh.jpg
    in /\w+\.sinaimg\.cn$/ => host, size, file
      @full_image_url = "https://#{host}/large/#{file}"

    # http://tw.weibo.com/1300957955/3786333853668537
    in "tw.weibo.com", /^\w+$/, /^\d+$/ => illust_long_id
      @illust_long_id = illust_long_id

    # http://weibo.com/3357910224/EEHA1AyJP
    # https://www.weibo.com/5501756072/IF9fugHzj?from=page_1005055501756072_profile&wvr=6&mod=weibotime
    in /weibo\.(com|cn)$/, /^\d+$/ => artist_short_id, /^\w+$/ => illust_base62_id
      @artist_short_id = artist_short_id
      @illust_base62_id = illust_base62_id

    # http://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t
    # http://photo.weibo.com/5732523783/talbum/detail/photo_id/4029784374069389?prel=p6_3
    in "photo.weibo.com", /^\d+$/ => artist_short_id, _, _, _, /^\d+$/ => illust_long_id, *rest
      @artist_short_id = artist_short_id
      @illust_long_id = illust_long_id

    # https://m.weibo.cn/detail/4506950043618873
    in "m.weibo.cn", "detail", /^\d+$/ => illust_long_id
      @illust_long_id = illust_long_id

    # https://m.weibo.cn/status/J33G4tH1B
    in "m.weibo.cn", "status", /^\w+$/ => illust_base62_id
      @illust_base62_id = illust_base62_id

    # https://www.weibo.com/u/5501756072
    # https://m.weibo.cn/profile/5501756072
    # https://m.weibo.cn/u/5501756072
    in _, ("u" | "profile"), /^\d+$/ => artist_short_id
      @artist_short_id = artist_short_id

    # https://www.weibo.com/p/1005055399876326 (short id: https://www.weibo.com/u/5399876326; username: https://www.weibo.com/chengziyou666)
    # https://www.weibo.com/p/1005055399876326/home?from=page_100505&mod=TAB&is_hot=1
    # https://www.weibo.cn/p/1005055399876326
    # https://m.weibo.com/p/1005055399876326
    in _, "p", /^\d+$/ => artist_long_id, *rest
      @artist_long_id = artist_long_id

    # https://www.weibo.com/5501756072
    # https://www.weibo.cn/5501756072
    # https://weibo.com/1843267214/profile
    in _, /^\d+$/ => artist_short_id, *rest
      @artist_short_id = artist_short_id

    # https://www.weibo.com/endlessnsmt (short id: https://www.weibo.com/u/1879370780)
    # https://www.weibo.cn/endlessnsmt
    in _, /^\w+$/ => artist_short_id
      @username = username

    else
    end
  end

  def image_url?
    full_image_url.present?
  end

  def profile_url
    if artist_short_id.present?
      "https://www.weibo.com/u/#{artist_short_id}"
    elsif artist_long_id.present?
      "https://www.weibo.com/p/#{artist_long_id}"
    elsif username.present?
      "https://www.weibo.com/#{username}"
    end
  end

  def mobile_url
    if @illust_long_id.present?
      "https://m.weibo.cn/detail/#{@illust_long_id}"
    elsif @illust_base62_id.present?
      "https://m.weibo.cn/status/#{@illust_base62_id}"
    end
  end

  def normalized_url
    if @artist_short_id.present? && @illust_base62_id.present?
      "https://www.weibo.com/#{@artist_short_id}/#{@illust_base62_id}"
    elsif mobile_url.present?
      mobile_url
    end
  end
end
