# frozen_string_literal: true

class Source::URL::Bcy < Source::URL
  attr_reader :drawer_id, :date, :page_url, :profile_url, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[bcy.net bcyimg.com])
  end

  def site_name
    "BCY"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://img5.bcyimg.com/drawer/103785/post/178q3/88fdb790392d11e7b58d17da09c22716.jpg/w650
    # https://img9.bcyimg.com/drawer/32360/post/178vu/46229ec06e8111e79558c1b725ebc9e6.jpg
    in _, "bcyimg.com", "drawer", drawer_id, "post", date_, file, *rest
      @drawer_id = drawer_id
      @date = date_.to_i(36).to_s # YYYYMMDD
      @full_image_url = "http://#{host}/drawer/#{drawer_id}/post/#{date_}/#{file}" # Use http:// because the SSL cert is expired.

    # https://bcy.net/u/1617969
    in _, "bcy.net", "u", user_id
      @profile_url = "https://bcy.net/u/#{user_id}"

    # https://bcy.net/illust/detail/1918/754976
    in _, "bcy.net", "illust", "detail", drawer_id, work_id
      @page_url = "https://bcy.net/illust/detail/#{drawer_id}/#{work_id}"

    # https://bcy.net/item/detail/6945012959928130597
    in _, "bcy.net", "item", "detail", item_id
      @page_url = "https://bcy.net/item/detail/#{item_id}"

    # https://p3-bcy.bcyimg.com/banciyuan/4aad9c6849ca46da86532cdef8b12e42~tplv-banciyuan-obj.image
    else
      nil
    end
  end

  def image_url?
    domain == "bcyimg.com"
  end
end
