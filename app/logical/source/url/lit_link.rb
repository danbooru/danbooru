# frozen_string_literal: true

class Source::URL::LitLink < Source::URL
  def self.match?(url)
    url.domain == "lit.link"
  end

  def parse
    case [domain, *path_segments]

    in "lit.link", ("en" | "ja"), username
      @username = username

    in "lit.link", username
      @username = username

    else
      nil
    end
  end

  def site_name
    "lit.link"
  end

  def image_url?
    false
  end

  def profile_url
    "https://lit.link/#{@username}" if @username.present?
  end
end
