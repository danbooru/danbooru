# frozen_string_literal: true

# Unhandled:
#
# http://t.cn/A6c3ZAE1 -> https://m.weibo.cn/status/4623322346685004
# http://weibo.sina.com/malson
# https://www.weibo.com/n/Windtalker10 (not the same as https://www.weibo.com/Windtalker10)
# http://blog.sina.com.cn/ayayayayayaya
# http://blog.sina.com.cn/u/1299088063

class Source::URL::Weibo < Source::URL
  RESERVED_USERNAMES = %w[u n p profile status detail]

  attr_reader :full_image_url, :artist_short_id, :artist_long_id, :illust_long_id, :illust_base62_id, :display_name, :username

  def self.match?(url)
    url.domain.in?(%w[weibo.com weibo.cn sinaimg.cn weibocdn.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://f.video.weibocdn.com/o0/wPhyi3dIlx086mr8Md3y01041200xT4N0E010.mp4?label=mp4_1080p&template=1080x1920.24.0&media_id=4914351942074379&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=v&ps=3lckmu&uid=3ZoTIp&ab=,3601-g32,8143-g0,8013-g0,3601-g32,3601-g37&Expires=1716316057&ssig=uW43Bg6Lo1&KID=unistore,video
    # https://f.us.sinaimg.cn/003K8vB7lx07rz92ubWg010412002UHB0E010.mp4?label=mp4_1080p&template=1920x1080.20.0&media_id=4339747921802209&tp=8x8A3El:YTkl0eM8&us=0&ori=1&bf=4&ot=h&lp=00002g58dE&ps=mZ6WB&uid=zszavag&ab=13038-g0,&Expires=1716411960&ssig=qmkXwFd%2B1m&KID=unistore,video
    # https://g.us.sinaimg.cn/o0/qNZcaAAglx07Wuf921CM0104120005tc0E010.mp4?label=gif_mp4
    in _, ("weibocdn.com" | "sinaimg.cn"), *rest if file_ext == "mp4"
      @full_image_url = with(params: params.slice(:Expires, :ssig, :KID)).to_s

    # http://ww1.sinaimg.cn/large/69917555gw1f6ggdghk28j20c87lbhdt.jpg
    # https://wx1.sinaimg.cn/large/002NQ2vhly1gqzqfk1agfj62981aw4qr02.jpg
    # http://ww4.sinaimg.cn/mw690/77a2d531gw1f4u411ws3aj20m816fagg.jpg (sample)
    # https://wx4.sinaimg.cn/orj360/e3930166gy1g546bz86cij20u00u040y.jpg (sample)
    # http://ww3.sinaimg.cn/mw1024/0065kjmOgw1fabcanrzx6j30f00lcjwv.jpg (sample)
    # https://wx1.sinaimg.cn/original/7004ec1cly1ge9dcbsw4lj20jg2ir7wh.jpg
    in _, "sinaimg.cn", size, file
      @full_image_url = "https://#{host}/large/#{file}"

    # http://tw.weibo.com/1300957955/3786333853668537
    in "tw", "weibo.com", /^\w+$/, /^\d+$/ => illust_long_id
      @illust_long_id = illust_long_id

    # http://weibo.com/3357910224/EEHA1AyJP
    # https://www.weibo.com/5501756072/IF9fugHzj?from=page_1005055501756072_profile&wvr=6&mod=weibotime
    in _, ("weibo.com" | "weibo.cn"), /^\d+$/ => artist_short_id, /^\w+$/ => illust_base62_id
      @artist_short_id = artist_short_id
      @illust_base62_id = illust_base62_id

    # http://photo.weibo.com/2125874520/wbphotos/large/mid/4194742441135220/pid/7eb64558gy1fnbryb5nzoj20dw10419t
    # http://photo.weibo.com/5732523783/talbum/detail/photo_id/4029784374069389?prel=p6_3
    in "photo", "weibo.com", /^\d+$/ => artist_short_id, _, _, _, /^\d+$/ => illust_long_id, *rest
      @artist_short_id = artist_short_id
      @illust_long_id = illust_long_id

    # https://m.weibo.cn/detail/4506950043618873
    # https://www.weibo.com/detail/4676597657371957
    in _, ("weibo.cn" | "weibo.com"), "detail", /^\d+$/ => illust_long_id
      @illust_long_id = illust_long_id

    # https://share.api.weibo.cn/share/304950356,4767694689143828.html
    # https://share.api.weibo.cn/share/304950356,4767694689143828
    in "share.api", "weibo.cn", "share", /^(\d+),(\d+)/
      @illust_long_id = $2

    # https://m.weibo.cn/status/J33G4tH1B
    in "m", "weibo.cn", "status", /^\w+$/ => illust_base62_id
      @illust_base62_id = illust_base62_id

    # https://www.weibo.com/u/5501756072
    # https://www.weibo.com/u/5957640693/home?wvr=5
    # https://m.weibo.cn/profile/5501756072
    # https://m.weibo.cn/u/5501756072
    in _, _, ("u" | "profile"), /^\d+$/ => artist_short_id, *rest
      @artist_short_id = artist_short_id

    # https://www.weibo.com/p/1005055399876326 (short id: https://www.weibo.com/u/5399876326; username: https://www.weibo.com/chengziyou666)
    # https://www.weibo.com/p/1005055399876326/home?from=page_100505&mod=TAB&is_hot=1
    # https://www.weibo.cn/p/1005055399876326
    # https://m.weibo.com/p/1005055399876326
    in _, _, "p", /^\d+$/ => artist_long_id, *rest
      @artist_long_id = artist_long_id

    # https://www.weibo.com/5501756072
    # https://www.weibo.cn/5501756072
    # https://weibo.com/1843267214/profile
    in _, _, /^\d+$/ => artist_short_id, *rest
      @artist_short_id = artist_short_id

    # https://weibo.com/n/肆巳4
    # https://www.weibo.com/n/小小男爵不要坑
    in _, _, "n", display_name, *rest
      @display_name = display_name

    # https://www.weibo.com/endlessnsmt (short id: https://www.weibo.com/u/1879370780)
    # https://www.weibo.cn/endlessnsmt
    # https://www.weibo.com/lvxiuzi0/home
    in _, _, /^\w+$/ => username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://weibo.com/tv/show/1034:4914351942074379?from=old_pc_videoshow
    # https://video.weibo.com/show?fid=1034:4914351942074379
    # https://weibo.com/ajax/common/download?pid=7eb64558gy1fnbry9mgx0j20dw104qjd
    else
      nil
    end
  end

  def profile_url
    if artist_short_id.present?
      "https://www.weibo.com/u/#{artist_short_id}"
    elsif artist_long_id.present?
      "https://www.weibo.com/p/#{artist_long_id}"
    elsif display_name.present?
      "https://www.weibo.com/n/#{display_name}"
    elsif username.present?
      "https://www.weibo.com/#{username}"
    end
  end

  def illust_id
    illust_long_id || illust_base62_id
  end

  def mobile_url
    if @illust_long_id.present?
      "https://m.weibo.cn/detail/#{@illust_long_id}"
    elsif @illust_base62_id.present?
      "https://m.weibo.cn/status/#{@illust_base62_id}"
    end
  end

  def page_url
    if @artist_short_id.present? && @illust_base62_id.present?
      "https://www.weibo.com/#{@artist_short_id}/#{@illust_base62_id}"
    elsif mobile_url.present?
      mobile_url
    end
  end
end
