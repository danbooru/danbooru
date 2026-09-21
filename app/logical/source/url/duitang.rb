# frozen_string_literal: true

class Source::URL::Duitang < Source::URL
  site "Duitang", url: "https://www.duitang.com"

  attr_reader :blog_id, :user_id, :album_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[duitang.com dtstatic.com])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.jpg
    # https://a-ssl.dtstatic.com/uploads/blog/202201/10/20220110201344_a992a.jpg
    # https://c-ssl.dtstatic.com/uploads/item/201812/02/20181202220613_cqgwb.thumb.400_0.jpg
    # https://c-ssl.dtstatic.com/uploads/avatar/202012/15/20201215234506_75e25.thumb.200_200_c.jpg
    in _, ("dtstatic.com" | "duitang.com"), "uploads", ("item" | "blog" | "avatar"), _, _, /\A\w+\./
      @full_image_url = without(:query).to_s.sub(/\.thumb\.\w+(?=\.\w+\z)/, "")

    # https://www.duitang.com/blog/?id=1026135391
    in _, "duitang.com", "blog", *_rest
      @blog_id = params[:id]

    # https://www.duitang.com/people/?id=9044306
    in _, "duitang.com", "people", *_rest
      @user_id = params[:id]

    # https://www.duitang.com/album/?id=81953329
    in _, "duitang.com", "album", *_rest
      @album_id = params[:id]

    else
      nil
    end
  end

  def image_url?
    domain == "dtstatic.com" || full_image_url.present?
  end

  def page_url
    "https://www.duitang.com/blog/?id=#{blog_id}" if blog_id.present?
  end

  def profile_url
    "https://www.duitang.com/people/?id=#{user_id}" if user_id.present?
  end
end
