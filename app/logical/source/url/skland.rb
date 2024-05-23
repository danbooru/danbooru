# frozen_string_literal: true

class Source::URL::Skland < Source::URL
  attr_reader :article_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[skland.com hycdn.cn])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp?x-oss-process=style/thumbnail (thumbnail)
    # https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp?x-oss-process=style/item_style (sample)
    # https://bbs.hycdn.cn/image/2024/04/29/576904/1dc98f0a6780ddcbc107d77bfdba673f.webp (full)
    # https://bbs.hycdn.cn/asset/avatar/f14b96b9ecde2cec279cf2281519e01b.webp
    in "bbs", "hycdn.cn", *rest
      @full_image_url = without(:params).to_s

    # https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/ceae138088e6ffb74cde2f255256f43d-sd.m3u8?auth_key=1716481288-d3ee979fabcb40ba81081ceb020d6c61-0-47eba7c0261297b87d9feb0688570de3
    # https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/96cc446b88a6338b2b8de003142cc1e7-hd.m3u8?auth_key=1716481288-ff1bfb8c15f647a684bf797c484b7410-0-2c37409b68fcafeedd167fad0dda8b05
    # https://skland-vod.hycdn.cn/302baa34192071efbfae5017f0e90102/ceae138088e6ffb74cde2f255256f43d-sd-00012.ts?auth_key=1716481288-d3ee979fabcb40ba81081ceb020d6c61-0-2d3d2648e49baf37d8bacd91cf9db666
    in "skland-vod", "hycdn.cn", *rest
      @full_image_url = to_s

    # https://www.skland.com/article?id=1827735
    # https://m.skland.com/article?id=1827735
    in _, "skland.com", "article"
      @article_id = params[:id]

    # https://www.skland.com/h/detail?id=611376
    in _, "skland.com", "h", "detail"
      @article_id = params[:id]

    # https://web.hycdn.cn/skland/site/assets/img/homeMainFirst.472886.png
    else
      nil
    end
  end

  def image_url?
    domain == "hycdn.cn"
  end

  def page_url
    "https://www.skland.com/article?id=#{article_id}" if article_id.present?
  end
end
