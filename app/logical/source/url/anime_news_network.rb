# frozen_string_literal: true

class Source::URL::AnimeNewsNetwork < Source::URL
  attr_reader :user_id

  def self.match?(url)
    url.domain.in?(%w[animenewsnetwork.com animenewsnetwork.cc])
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://www.animenewsnetwork.com/encyclopedia/people.php?id=17056
    in _, _, "encyclopedia", "people.php" if params[:id].present?
      @user_id = params[:id]
    else
      nil
    end
  end

  def site_name
    "Anime News Network"
  end

  def profile_url
    "https://www.animenewsnetwork.com/encyclopedia/people.php?id=#{user_id}" if user_id.present?
  end
end
