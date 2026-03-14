# frozen_string_literal: true

class Source::URL::Anidb < Source::URL
  attr_reader :user_id

  def self.match?(url)
    url.domain == "anidb.net"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://anidb.net/creator/65313
    in _, "anidb.net", "creator", user_id
      @user_id = user_id

    # https://anidb.net/perl-bin/animedb.pl?show=creator&creatorid=3903
    in _, "anidb.net", "perl-bin", "animedb.pl" if params[:show] == "creator" && params[:creatorid].present?
      @user_id = params[:creatorid]

    else
      nil
    end
  end

  def profile_url
    "https://anidb.net/creator/#{user_id}" if user_id.present?
  end
end
