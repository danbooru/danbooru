module Sources
  module Strategies
    def self.all
      return [
        Strategies::Pixiv, 
        Strategies::NicoSeiga, 
        Strategies::Twitter, 
        Strategies::Stash, # must come before DeviantArt
        Strategies::DeviantArt, 
        Strategies::Tumblr, 
        Strategies::ArtStation, 
        Strategies::Nijie, 
        Strategies::Pawoo,
        Strategies::Moebooru,
      ]
    end

    def self.find(url, referer=nil, default: Strategies::Null)
      strategy = all.detect { |strategy| strategy.match?(url, referer) } || default
      strategy&.new(url, referer)
    end

    def self.canonical(url, referer)
      find(url, referer).canonical_url
    end
  end
end
