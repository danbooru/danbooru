module Sources
  module Strategies
    def self.all
      [
        Strategies::Pixiv,
        Strategies::Fanbox,
        Strategies::NicoSeiga,
        Strategies::Twitter,
        Strategies::Stash, # must come before DeviantArt
        Strategies::DeviantArt,
        Strategies::Tumblr,
        Strategies::ArtStation,
        Strategies::Nijie,
        Strategies::Pawoo,
        Strategies::Moebooru,
        Strategies::HentaiFoundry,
        Strategies::Weibo,
        Strategies::Newgrounds
      ]
    end

    def self.find(url, referer = nil, default: Strategies::Null)
      strategy = all.map { |strategy| strategy.new(url, referer) }.detect(&:match?)
      strategy || default&.new(url, referer)
    end

    def self.canonical(url, referer)
      find(url, referer).canonical_url
    end

    def self.normalize_source(url)
      find(url).normalize_for_source || url
    end
  end
end
