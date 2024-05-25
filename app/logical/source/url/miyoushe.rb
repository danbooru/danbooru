# frozen_string_literal: true

# @see Source::Extractor::Miyoushe
class Source::URL::Miyoushe < Source::URL
  attr_reader :user_id, :subsite, :article_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[mihoyo.com miyoushe.com hoyolab.com])
  end

  def site_name
    (domain == "hoyolab.com") ? "Hoyolab" : "Miyoushe"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://upload-bbs.miyoushe.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg?x-oss-process=image/resize,s_600/quality,q_80/auto-orient,0/interlace,1/format,jpg (sample)
    # https://upload-bbs.miyoushe.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg (full)
    # https://upload-bbs.mihoyo.com/upload/2022/09/14/73731802/2e25565bd6fa86d86b581e151e9778ac_8107601733815763725.jpg (full, redirects to miyoushe.com)
    in "upload-bbs", ("mihoyo.com" | "miyoushe.com"), "upload", *rest
      @full_image_url = with(site: "https://upload-bbs.mihoyo.com").without(:params).to_s

    # https://upload-os-bbs.hoyolab.com/upload/2022/12/25/58551199/3356bf88b08fdc8aaa5b5e6b26f70d23_5122589414918681540.jpg?x-oss-process=image%2Fresize%2Cs_1000%2Fauto-orient%2C0%2Finterlace%2C1%2Fformat%2Cwebp%2Fquality%2Cq_80
    in "upload-os-bbs", "hoyolab.com", "upload", *rest
      @full_image_url = without(:params).to_s

    # https://prod-vod-sign.miyoushe.com/ooKvbeTisEJIQWJ35PqPsGMFC9iyz4h1gQzAAN?auth_key=1716561874-d87f81457c-0-fdd0dd6514dd0e6f612a312448908500
    in "prod-vod-sign", "miyoushe.com", *rest
      @full_image_url = to_s

    # https://bbs.mihoyo.com/bh3/article/28939887
    # https://www.miyoushe.com/bh3/article/28939887
    # https://www.miyoushe.com/bh2/article/52917106
    # https://www.miyoushe.com/dby/article/44714029
    # https://www.miyoushe.com/ys/article/38961158
    # https://www.miyoushe.com/sr/article/53098212
    # https://www.miyoushe.com/zzz/article/37712337
    # https://www.miyoushe.com/wd/article/53070231
    in _, ("mihoyo.com" | "miyoushe.com"), subsite, "article", article_id
      @subsite = subsite
      @article_id = article_id

    # https://www.hoyolab.com/article/14554718
    in _, "hoyolab.com", "article", article_id
      @article_id = article_id

    # https://www.hoyolab.com/genshin/article/196109
    in _, "hoyolab.com", "genshin", "article", article_id
      @article_id = article_id

    # https://bbs.mihoyo.com/bh3/accountCenter/postList?id=73731802
    # https://www.miyoushe.com/bh3/accountCenter/postList?id=73731802
    # https://www.miyoushe.com/sr/accountCenter/replyList?id=73731802
    in _, ("mihoyo.com" | "miyoushe.com"), subsite, "accountCenter", *rest if params[:id].present?
      @subsite = subsite
      @user_id = params[:id]

    # https://www.hoyolab.com/accountCenter/postList?id=58551199
    in _, "hoyolab.com", "accountCenter", *rest if params[:id].present?
      @user_id = params[:id]

    # https://m.bbs.mihoyo.com/bh3?channel=miyousheluodi%2F#/article/27266673
    # https://m.miyoushe.com/bh3?channel=miyousheluodi%2F#/article/27266673
    # https://m.miyoushe.com/bh3/#/accountCenter/0?id=275785895
    in _, ("mihoyo.com" | "miyoushe.com"), subsite if fragment&.starts_with?("/")
      url = Source::URL.parse("https://www.miyoushe.com/#{subsite}#{fragment}")
      @subsite = subsite
      @article_id = url.try(:article_id)
      @user_id = url.try(:user_id)

    # https://m.hoyolab.com/#/article/28583736?utm_source=sns&utm_medium=twitter&utm_id=2
    # https://m.hoyolab.com/#/contribution/121
    in "m", "hoyolab.com" if fragment&.starts_with?("/")
      url = Source::URL.parse("https://www.hoyolab.com#{fragment}")
      @article_id = url.try(:article_id)
      @user_id = url.try(:user_id)

    # https://wiki.hoyolab.com/pc/hsr/entry/805
    # https://bbs.mihoyo.com/sr/wiki/content/2083/detail
    # https://act.mihoyo.com/puzzle/hkrpg/pz_stKK3ccUXV/index.html
    # https://act-upload.mihoyo.com/sr-wiki/2023/12/12/279865110/71407be63242f3b5ef6c73cbd12a4d0b_708709569307330375.png
    # https://webstatic.mihoyo.com/upload/event/2023/08/10/40131b779e708c2f9f464ea7424e8773_4631307118561606922.jpg
    # https://fastcdn.mihoyo.com/content-v2/bh3/123597/8f1de24a73389679410f3503f8939ae5_4495642643745785394.png
    else
      nil
    end
  end

  def image_url?
    super || subdomain == "prod-vod-sign"
  end

  def base_url(subsite: self.subsite)
    if site_name == "Hoyolab"
      "https://www.hoyolab.com"
    else
      "https://www.miyoushe.com/#{subsite || "sr"}"
    end
  end

  def page_url
    "#{base_url}/article/#{article_id}" if article_id.present?
  end

  def profile_url
    # We normalize the subsite to /sr/ because it doesn't actually matter and so that artist URLs are consistent for artist finding purposes.
    "#{base_url(subsite: "sr")}/accountCenter/postList?id=#{user_id}" if user_id.present?
  end
end
