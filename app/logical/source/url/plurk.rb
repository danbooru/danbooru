# frozen_string_literal: true

class Source::URL::Plurk < Source::URL
  RESERVED_USERNAMES = %w[
    aboutUs app brandInfo contact content-policy f help hotlinks login logout m news p portal privacy qrcode s search settings
    signup terms top u EmoticonManager2 Friends Photos UserRecommend
  ]

  attr_reader :username, :work_id, :response_id

  def self.match?(url)
    url.domain == "plurk.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg
    # https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg
    in _, "plurk.com", /^(mx_)?(\w{22})\.(\w+)$/ if image_url?
      @image_id = $2

    # https://www.plurk.com/p/om6zv4
    # https://www.plurk.com/p/3fscrz09wq?r=630693629487611
    in _, "plurk.com", "p", work_id
      @work_id = work_id
      @response_id = params[:r]

    # https://www.plurk.com/m/p/okxzae
    # https://www.plurk.com/m/p/okxzae?r=7590694648
    # https://www.plurk.com/s/p/3frqa0mcw9
    # https://www.plurk.com/s/p/3frqa0mcw9?r=630644531195980
    in _, "plurk.com", ("m" | "s"), "p", work_id
      @work_id = work_id
      @response_id = params[:r]

    # https://www.plurk.com/m/redeyehare
    # https://www.plurk.com/m/redeyehare/fans
    # https://www.plurk.com/u/ddks2923
    in _, "plurk.com", ("m" | "u"), username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.plurk.com/m/u/leiy1225
    # https://www.plurk.com/m/u/leiy1225/fans
    # https://www.plurk.com/s/u/salmonroe13
    # https://www.plurk.com/s/u/salmonroe13/fans
    in _, "plurk.com", ("m" | "s"), "u", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.plurk.com/redeyehare
    # https://www.plurk.com/RSSSww/invite/4
    in _, "plurk.com", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.plurk.com/f/plurk_campsite
    # https://www.plurk.com/f/plurk_campsite/p/3fse0ndv8t
    else
      nil
    end
  end

  def image_url?
    host == "images.plurk.com"
  end

  def page_url
    if work_id.present? && response_id.present?
      "https://www.plurk.com/p/#{work_id}?r=#{response_id}"
    elsif work_id.present?
      "https://www.plurk.com/p/#{work_id}"
    end
  end

  def profile_url
    "https://www.plurk.com/#{username}" if username.present?
  end
end
