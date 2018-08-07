module Sources
  module Strategies
    def self.all
      return [
        Strategies::Pixiv, 
        Strategies::NicoSeiga, 
        Strategies::Twitter, 
        Strategies::DeviantArt, 
        Strategies::Tumblr, 
        Strategies::ArtStation, 
        Strategies::Nijie, 
        Strategies::Pawoo,
        Strategies::Moebooru,

        Strategies::Null # MUST BE LAST!
      ]
    end

    def self.find(url, referer=nil)
      all
        .detect { |strategy| strategy.match?(url, referer) }
        .new(url, referer)
    end

    def self.canonical(url, referer)
      find(url, referer).canonical_url
    end
  end
end
