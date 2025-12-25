# frozen_string_literal: true

# @see Source::Extractor::Piapro
class Source::URL::Piapro < Source::URL
  RESERVED_USERNAMES = %w[
    3dm a about_us bookmark characters content content_list_recommend dm download faq follow help illust intro inquiry
    license logout mailto music my_page official_collabo privacypolicy product r t text timg user user_agreement user_mod
  ]

  attr_reader :username, :post_id, :content_id, :full_image_url

  def self.match?(url)
    url.domain == "piapro.jp"
  end

  def site_name
    "Piapro.jp"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0250_0250.png (thumbnail)
    # https://cdn.piapro.jp/thumb_i/w2/w22xmltnyzcsrqxu_20240303200945_0860_0600.png (sample)
    # https://cdn.piapro.jp/thumb_i/74/74w6x4s2s39aag5q_20240325172302_0860_0600.png (sample)
    in "cdn", "piapro.jp", "thumb_i", _, /^([a-z0-9]+)_\d{14}_\d{4}_\d{4}/
      @content_id = $1

    # https://dl.piapro.jp/image/w2/w22xmltnyzcsrqxu_20240303200945.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584%25E7%2597%259B%25E3%2581%2584_nibiirooo__202404301346.png&Expires=1714452547&Signature=j3CPYYLRaTQcQqz6g-zvhOQfIeKnrxRBcxtW6sARJ7xlU3nnfkBAx44RjD6tzfjCH5c~t-50D-A4O9tjWKbRDZI9h3~qbYagz3MYcM-Do-PfMGHaNakpZ51F7fDRby-a7NFou8i4e9HpVJ0By1oTNo650ERbM2FPoZl6thOTfXhFK06pF5yd~lNk2UgaPNQpZJ3Ah4VgRhA~SIWlPkLBIdHjqHTBMtFAKZ-RrNhz3DXphxvAQyuQYjGJCL-UZXYzWGQK5Q73dim0~Y8TTI8eAQdWJLY7rwxtJ5D0zeh1Nue-YA-Tqo-b1mTbvcJrumLAAgT1AwmD~BfiOncRNs4XZw__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA (full)
    # https://dl.piapro.jp/image/74/74w6x4s2s39aag5q_20240325172302.png?response-content-disposition=attachment%3B%20filename%2A%3DUTF-8%27%27%25E6%25B6%2599_Akechannogohan_202404301415.png&Expires=1714454339&Signature=k4gz3x~zUfDsVXC-C2R31Y-6d~2e2KN~oyDm7h4H0mTkIzzimVXU1pgRpxImBAAk2dXKXbuVRO6RRmYFqjSgdjrY~mcdsL0c7IcxTg8eUqKHnAG6OfabO~F3knSWh7WZbfKn3tjrKRffh-9xqyq3gQ5zIkaIJiK~N--gV2m68dIxHKDgpseiC4wr2pKCDog~GKPNW7~X71zWblaNVS527BA~y~1qJ~84yYZPDluGLEpIkDGXzW7D9HPTOyj8lYdFH7YVTMedbgwo1aWK6l8nVF99Ku~Urh9myNOn6Y1nyqxZtJW3BnLDle~aEw8pvxsLHHgjx~VjBMks5zChPRGIxQ__&Key-Pair-Id=APKAIJPPZV4JCCSOERBA
    in "dl", "piapro.jp", "image", _, /^([a-z0-9]+)_\d{14}/
      @content_id = $1
      @full_image_url = to_s

    # https://blog.piapro.jp/2024/04/g2404291.html
    in "blog", "piapro.jp", *rest
      nil

    # https://piapro.jp/t/_J0y (https://piapro.jp/content/w22xmltnyzcsrqxu)
    # http://piapro.jp/t/zXLG/20101206161601
    in _, "piapro.jp", "t", post_id, *rest
      @post_id = post_id

    # https://piapro.jp/content/zja2063m7x4yfjvk (https://piapro.jp/t/1jCS)
    in _, "piapro.jp", "content", content_id
      @content_id = content_id

    # https://piapro.jp/my_page/?view=profile&pid=orzkakkokari
    # https://piapro.jp/my_page/?pid=soudapasuta157
    # https://piapro.jp/my_page/?piaproId=sakira
    in _, "piapro.jp", "my_page", *rest if params[:pid].present? || params[:piaproId].present?
      @username = params[:pid] || params[:piaproId]

    # https://piapro.jp/nibiirooo_
    in _, "piapro.jp", username, *rest unless username.in?(RESERVED_USERNAMES) || image_url?
      @username = username

    # https://cdn.piapro.jp/icon_u/626/1485626_20230224204244_0072.jpg (profile picture)
    # http://piapro.jp/download/?id=5u2scvk5lp74f1ec&view=content_file&sub_id=1
    # http://c1.piapro.jp/timg/ezjs3xrmu0nof2mc_20120629224737_0500_0500.jpg
    # http://piapro.jp/content/?id=0dgbuzugxtp7fm2k&cdate=2011-06-01%2014%3A35%3A52
    # http://piapro.jp/a/content/?id=ncdt0qjsdpdb0lrk
    else
      nil
    end
  end

  def page_url
    if post_id.present?
      "https://piapro.jp/t/#{post_id}"
    elsif content_id.present?
      "https://piapro.jp/content/#{content_id}"
    end
  end

  def profile_url
    "https://piapro.jp/#{username}" if username.present?
  end
end
