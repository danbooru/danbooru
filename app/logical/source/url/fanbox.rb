# frozen_string_literal: true

class Source::URL::Fanbox < Source::URL
  RESERVED_SUBDOMAINS = %w[www downloads]

  attr_reader :username, :user_id, :work_id

  def self.match?(url)
    url.domain == "fanbox.cc" || url.host == "fanbox.pixiv.net" || (url.domain.in?(%w[pixiv.net pximg.net]) && url.path.include?("/fanbox/"))
  end

  def parse
    case [host, *path_segments]

    # https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png (full res)
    # https://downloads.fanbox.cc/images/post/39714/c/1200x630/JvjJal8v1yLgc5DPyEI05YpT.jpeg (sample)
    # https://downloads.fanbox.cc/images/post/39714/w/1200/JvjJal8v1yLgc5DPyEI05YpT.jpeg (sample)
    # https://fanbox.pixiv.net/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png (old)
    in ("downloads.fanbox.cc" | "fanbox.pixiv.net"), "images", "post", work_id, *rest
      @work_id = work_id

    # https://pixiv.pximg.net/c/1200x630_90_a2_g5/fanbox/public/images/post/186919/cover/VCI1Mcs2rbmWPg0mmiTisovn.jpeg
    # https://pixiv.pximg.net/fanbox/public/images/post/186919/cover/VCI1Mcs2rbmWPg0mmiTisovn.jpeg
    in [*, "fanbox", "public", "images", "post", work_id, *] if image_url?
      @work_id = work_id

    # https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg
    # https://pixiv.pximg.net/c/1620x580_90_a2_g5/fanbox/public/images/creator/1566167/cover/QqxYtuWdy4XWQx1ZLIqr4wvA.jpeg
    # https://pixiv.pximg.net/fanbox/public/images/creator/1566167/profile/Ix6bnJmTaOAFZhXHLbWyIY1e.jpeg (dead URL type)
    in [*, "fanbox", "public", "images", "creator", user_id, *] if image_url?
      @user_id = user_id

    # https://www.fanbox.cc/@tsukiori/posts/1080657
    in "www.fanbox.cc", /^@/ => username, "posts", work_id
      @username = username.delete_prefix("@")
      @work_id = work_id

    # https://www.pixiv.net/fanbox/creator/1566167/post/39714 (old)
    in "www.pixiv.net", "fanbox", "creator", user_id, "post", work_id
      @user_id = user_id
      @work_id = work_id

    # https://www.pixiv.net/fanbox/creator/1566167
    # http://www.pixiv.net/fanbox/user/3410642
    # https://www.pixiv.net/fanbox/creator/18915237/post
    in "www.pixiv.net", "fanbox", ("creator" | "user"), user_id, *rest
      @user_id = user_id

    # http://www.pixiv.net/fanbox/member.php?user_id=3410642
    in "www.pixiv.net", "fanbox", "member.php" if params[:user_id].present?
      @user_id = user_id

    # https://omu001.fanbox.cc/posts/39714
    # https://brllbrll.fanbox.cc/posts/626093 (R-18)
    in /fanbox\.cc/, "posts", work_id unless subdomain.in?(RESERVED_SUBDOMAINS)
      @username = subdomain
      @work_id = work_id

    # https://omu001.fanbox.cc
    # https://omu001.fanbox.cc/posts
    # https://omu001.fanbox.cc/plans
    in /fanbox\.cc/, *rest unless subdomain.in?(RESERVED_SUBDOMAINS)
      @username = subdomain

    else
    end
  end

  def image_url?
    host.in?(%w[pixiv.pximg.net fanbox.pixiv.net downloads.fanbox.cc])
  end

  def full_image_url
    # https://downloads.fanbox.cc/images/post/39714/w/1200/JvjJal8v1yLgc5DPyEI05YpT.jpeg (full: https://downloads.fanbox.cc/images/post/39714/JvjJal8v1yLgc5DPyEI05YpT.png)
    # https://downloads.fanbox.cc/images/post/39714/c/1200x630/JvjJal8v1yLgc5DPyEI05YpT.jpeg
    # https://pixiv.pximg.net/c/936x600_90_a2_g5/fanbox/public/images/plan/4635/cover/L6AZNneFuHW6r25CHHlkpHg4.jpeg
    # https://pixiv.pximg.net/c/400x400_90_a2_g5/fanbox/public/images/creator/1566167/profile/BtxSp9MImFhnEZtjEZs2RPqL.jpeg
    to_s.gsub(%r{/[cw]/\w+/}, "/") if image_url?
  end

  def profile_url
    if username.present?
      "https://#{username}.fanbox.cc"
    elsif user_id.present?
      "https://www.pixiv.net/fanbox/creator/#{user_id}"
    end
  end
end
