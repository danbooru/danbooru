# frozen_string_literal: true

class Source::URL::Xfolio < Source::URL
  attr_reader :username, :work_id, :image_id

  def self.match?(url)
    url.domain == "xfolio.jp"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://xfolio.jp/fullscale_image?image_id=1128032&work_id=237599
    in _, "xfolio.jp", "fullscale_image" if params["image_id"].present? && params["work_id"].present?
      @work_id = params["work_id"]
      @image_id = params["image_id"]

    # https://xfolio.jp/user_asset.php?id=1128032&work_id=237599&work_image_id=1128032&type=work_image
    in _, "xfolio.jp", "user_asset.php" if params["work_image_id"].present? && params["work_id"].present?
      @work_id = params["work_id"]
      @image_id = params["work_image_id"]

    # https://xfolio.jp/en/portfolio/ben1shoga/works/237599
    # https://xfolio.jp/portfolio/ben1shoga/works/237599
    in _, "xfolio.jp", *, "portfolio", username, "works", work_id
      @username = username
      @work_id = work_id

    # https://xfolio.jp/en/portfolio/ben1shoga
    # https://xfolio.jp/en/portfolio/ben1shoga/works
    in _, "xfolio.jp", _, "portfolio", username, *rest
      @username = username

    # https://xfolio.jp/portfolio/ben1shoga
    # https://xfolio.jp/portfolio/ben1shoga/works
    in _, "xfolio.jp", "portfolio", username, *rest
      @username = username

    else
      nil
    end
  end

  def image_url?
    path.starts_with?("/user_asset.php")
  end

  def page_url
    "https://xfolio.jp/portfolio/#{username}/works/#{work_id}" if username.present? && work_id.present?
  end

  def profile_url
    "https://xfolio.jp/portfolio/#{username}" if username.present?
  end
end
