# frozen_string_literal: true

module Sources
  module Strategies
    def self.all
      [
        Strategies::Pixiv,
        Strategies::Twitter,
        Strategies::Tumblr,
        Strategies::NicoSeiga,
        Strategies::DeviantArt,
        Strategies::Moebooru,
        Strategies::Nijie,
        Strategies::ArtStation,
        Strategies::HentaiFoundry,
        Strategies::Fanbox,
        Strategies::Mastodon,
        Strategies::PixivSketch,
        Strategies::Weibo,
        Strategies::Newgrounds,
        Strategies::Skeb,
        Strategies::Lofter,
        Strategies::Foundation,
        Strategies::Plurk,
        Strategies::Tinami,
        Strategies::Fantia,
      ]
    end

    def self.find(url, referer = nil, default: Strategies::Null)
      strategy = all.lazy.map { |s| s.new(url, referer) }.detect(&:match?)
      strategy || default&.new(url, referer)
    end

    def self.canonical(url, referer)
      find(url, referer).canonical_url
    end
  end
end
