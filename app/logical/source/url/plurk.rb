# frozen_string_literal: true

class Source::URL::Plurk < Source::URL
  attr_reader :username, :work_id

  def self.match?(url)
    url.domain == "plurk.com"
  end

  def parse
    case [domain, *path_segments]

    # https://images.plurk.com/5wj6WD0r6y4rLN0DL3sqag.jpg
    # https://images.plurk.com/mx_5wj6WD0r6y4rLN0DL3sqag.jpg
    in "plurk.com", /^(mx_)?(\w{22})\.(\w+)$/ if image_url?
      @image_id = $2

    # https://www.plurk.com/p/om6zv4
    in "plurk.com", "p", work_id
      @work_id = work_id

    # https://www.plurk.com/m/p/okxzae
    in "plurk.com", "m", "p", work_id
      @work_id = work_id

    # https://www.plurk.com/m/redeyehare
    in "plurk.com", "m", username
      @username = username

    # https://www.plurk.com/u/ddks2923
    in "plurk.com", "u", username
      @username = username

    # https://www.plurk.com/m/u/leiy1225
    in "plurk.com", "m", "u", username
      @username = username

    # https://www.plurk.com/s/u/salmonroe13
    in "plurk.com", "s", "u", username
      @username = username

    # https://www.plurk.com/redeyehare
    # https://www.plurk.com/RSSSww/invite/4
    in "plurk.com", username, *rest
      @username = username

    else
      nil
    end
  end

  def image_url?
    host == "images.plurk.com"
  end

  def page_url
    "https://www.plurk.com/p/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://www.plurk.com/#{username}" if username.present?
  end
end
