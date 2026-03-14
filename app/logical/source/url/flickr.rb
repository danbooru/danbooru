# frozen_string_literal: true

class Source::URL::Flickr < Source::URL
  attr_reader :username

  def self.match?(url)
    url.domain.in?(%w[flickr.com staticflickr.com])
  end

  def parse
    case [subdomain, domain, *path_segments]
    # https://www.flickr.com/people/shirasaki408/
    # https://www.flickr.com/photos/shirasaki408/
    # https://www.flickr.com/photos/shirasaki408/albums
    # https://www.flickr.com/photos/hizna/sets/72157629448846789/
    # https://www.flickr.com/photos/shirasaki408/49398982266/
    in _, "flickr.com", ("people" | "photos"), username, *_rest
      @username = username
    else
      nil
    end
  end

  def profile_url
    "https://www.flickr.com/people/#{username}" if username.present?
  end
end
