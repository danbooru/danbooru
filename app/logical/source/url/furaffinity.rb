# frozen_string_literal: true

class Source::URL::Furaffinity < Source::URL
  attr_reader :work_id, :username, :filename

  def self.match?(url)
    url.domain.in?(%w[furaffinity.net fxraffinity.net fxfuraffinity.net vxfuraffinity.net xfuraffinity.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://www.furaffinity.net/view/46821705/
    # https://www.furaffinity.net/view/46802202/ (scrap)
    # https://www.furaffinity.net/full/46821705/
    in _, _, ("view" | "full"), /^\d+$/ => work_id
      @work_id = work_id

    # https://d.furaffinity.net/art/iwbitu/1650222955/1650222955.iwbitu_yubi.jpg
    # https://t.furaffinity.net/46821705@800-1650222955.jpg
    # https://a.furaffinity.net/1550854991/iwbitu.gif
    in _, "furaffinity.net", "art", username, subdir, filename
      @username = username
      @filename = filename

    # https://www.furaffinity.net/gallery/iwbitu
    # https://www.furaffinity.net/scraps/iwbitu/2/?
    # https://www.furaffinity.net/gallery/iwbitu/folder/133763/Regular-commissions
    # https://www.furaffinity.net/user/lottieloveart/user?user_id=1021820442510802945
    # https://www.furaffinity.net/stats/duskmoor/submissions/
    in _, "furaffinity.net", ("gallery" | "user" | "favorites" | "scraps" | "journals" | "stats"), username, *pages
      @username = username

    else
      nil
    end
  end

  def image_url?
    @filename.present?
  end

  def page_url
    "https://www.furaffinity.net/view/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://www.furaffinity.net/user/#{username}" if username.present?
  end
end
