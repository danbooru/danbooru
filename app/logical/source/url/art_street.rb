# frozen_string_literal: true

class Source::URL::ArtStreet < Source::URL
  attr_reader :picture_id, :book_id, :full_image_url, :author_id, :user_id

  def self.match?(url)
    url.domain == "medibang.com" || url.host.in?(%w[dthezntil550i.cloudfront.net dqmk835cy5zzx.cloudfront.net])
  end

  def site_name
    "ArtStreet"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://medibang.com/picture/4b2112261505098280008769655/
    in _, "medibang.com", "picture", picture_id
      @picture_id = picture_id
      @author_id = picture_id[17..].to_i

    # https://medibang.com/book/f72107281839259430002176282/
    # https://medibang.com/viewer/f72107281839259430002176282/
    in _, "medibang.com", ("book" | "viewer"), book_id
      @book_id = book_id
      @author_id = book_id[17..].to_i

    # https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/dd808367-6027-42bb-b458-1500e7774d8d.png (original)
    # https://dthezntil550i.cloudfront.net/4b/latest/4b2112261505098280008769655/1280_960/d5b22a94-4864-45d5-96e7-cbca9e0043f4.png (sample)
    in _, "cloudfront.net", subdir, "latest", picture_id, *size, file
      @picture_id = picture_id
      @author_id = picture_id[17..].to_i
      @full_image_url = "https://dthezntil550i.cloudfront.net/#{subdir}/latest/#{picture_id}/#{file}"

    # https://dthezntil550i.cloudfront.net/f7/current/f72107281839259430002176282/0936fedf-f270-442b-bd75-a44c4c392198.jpg?viewer=1
    # https://dqmk835cy5zzx.cloudfront.net/f7/current/f72107281839259430002176282/798080e1-1361-49c0-84aa-06518bdf1a22.jpg?Policy=eyJTdGF0ZW1lbnQiOlt7IlJlc291cmNlIjoiaHR0cHM6Ly9kcW1rODM1Y3k1enp4LmNsb3VkZnJvbnQubmV0L2Y3L2N1cnJlbnQvZjcyMTA3MjgxODM5MjU5NDMwMDAyMTc2MjgyLyoiLCJDb25kaXRpb24iOnsiRGF0ZUxlc3NUaGFuIjp7IkFXUzpFcG9jaFRpbWUiOjE2ODAxMTMzNzB9fX1dfQ__&Signature=QG35KafzMXXY1hlsXnJHKnlZYU~hBrduhfh-StKFhudNRLNFbidoeGsF1pnVhyeHJQNdRkRg6WwErw-q35HIZLxoC5ugWY64tdnY-l6H1rI-M2mSIiMkYEDUP6mqBXCgObZaCV6Lk6b18s~trzbXbYO9cMVDvJ5DSvMJb1f1G~pDBbSsgulVRNUppQcPqjM3ObvRqsRtEMxwjuafEJ33JmfVTr-hUzk-ncTL-MegEiC7qFaT0o08cHKXO4385JBUt8S6ZcNch-EvNbEXIxUsK-XH-VeAy93cuJ~Ez0VioZarwlFejXH0K--b2lzwwroqGfke4gVFH0I4Skc4GVnF9g__&Key-Pair-Id=APKAI322DZTKDWD5CY2Q
    in _, "cloudfront.net", subdir, "current", book_id, file
      @book_id = book_id
      @author_id = book_id[17..].to_i
      @full_image_url = original_url

    # https://dthezntil550i.cloudfront.net/86/0008769655/51baf965-d529-4841-87a1-319cfe2404fd.jpg (profile image)
    in _, "cloudfront.net", subdir, author_id, file
      @author_id = author_id.to_i

    # https://medibang.com/author/8769655/ (redirects to https://medibang.com/u/16672238/)
    # https://medibang.com/author/272687/activities/?type=2
    in _, "medibang.com", "author", author_id, *rest
      @author_id = author_id

    # https://medibang.com/u/16672238/
    # https://medibang.com/u/16672238/gallery/?cat=illust
    in _, "medibang.com", "u", user_id, *rest
      @user_id = user_id

    else
      nil
    end
  end

  def image_url?
    domain == "cloudfront.net"
  end

  def page_url
    if picture_id.present?
      "https://medibang.com/picture/#{picture_id}/"
    elsif book_id.present?
      "https://medibang.com/book/#{book_id}/"
    end
  end

  def profile_url
    if author_id.present?
      "https://medibang.com/author/#{author_id}/"
    elsif user_id.present?
      "https://medibang.com/u/#{user_id}/"
    end
  end
end
