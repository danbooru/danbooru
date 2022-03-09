# frozen_string_literal: true

# A Source::URL is a URL from a source site, such as Twitter, Pixiv, etc. Each site has a
# subclass responsible for parsing and extracting information from URLs for that site.
#
# To add a new site, create a subclass of Source::URL and implement `#match?` to define
# which URLs belong to the site, and `#parse` to parse and extract information from the URL.
#
# Source::URL is a subclass of Danbooru::URL, so it inherits some common utility methods
# from there.
#
# @example
#   url = Source::URL.parse("https://twitter.com/yasunavert/status/1496123903290314755")
#   url.site_name        # => "Twitter"
#   url.status_id        # => "1496123903290314755"
#   url.twitter_username # => "yasunavert"
#
module Source
  class URL < Danbooru::URL
    SUBCLASSES = [
      Source::URL::Twitter,
      Source::URL::ArtStation,
      Source::URL::Fanbox,
      Source::URL::Foundation,
      Source::URL::HentaiFoundry,
      Source::URL::Lofter,
      Source::URL::Mastodon,
      Source::URL::Moebooru,
      Source::URL::Nijie,
      Source::URL::Newgrounds,
      Source::URL::PixivSketch,
      Source::URL::Plurk,
      Source::URL::Skeb,
      Source::URL::Tumblr,
      Source::URL::TwitPic,
      Source::URL::Weibo,
    ]

    # Parse a URL into a subclass of Source::URL, or raise an exception if the URL is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Source::URL]
    def self.parse!(url)
      url = Danbooru::URL.new(url)
      subclass = SUBCLASSES.find { |c| c.match?(url) } || Source::URL
      subclass.new(url)
    end

    # Parse a string into a URL, or return nil if the string is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Danbooru::URL]
    def self.parse(url)
      parse!(url)
    rescue Error
      nil
    end

    # Subclasses should implement this to return true for URLs that should be handled by the subclass.
    #
    # @param url [Danbooru::URL] The source URL.
    def self.match?(url)
      raise NotImplementedError
    end

    # @return [String, nil] The name of the site this URL belongs to, or possibly nil if unknown.
    def site_name
      self.class.name.demodulize.titleize
    end

    protected def initialize(...)
      super(...)
      parse
    end

    # Subclasses should implement this to parse and extract any useful information from
    # the URL. This is called when the URL is initialized.
    protected def parse
    end
  end
end
