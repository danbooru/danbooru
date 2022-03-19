# frozen_string_literal: true

# A Source::URL is a URL from a source site, such as Twitter, Pixiv, etc. Each site has a
# subclass responsible for parsing and extracting information from URLs for that site.
#
# Sources::Strategies are the main user of Source::URLs. Each Source::URL subclass usually
# has a corresponding strategy for extracting data from that site.
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
# @see Danbooru::URL
module Source
  class URL < Danbooru::URL
    SUBCLASSES = [
      Source::URL::Pixiv,
      Source::URL::Twitter,
      Source::URL::ArtStation,
      Source::URL::DeviantArt,
      Source::URL::Fanbox,
      Source::URL::Fantia,
      Source::URL::Fc2,
      Source::URL::Foundation,
      Source::URL::HentaiFoundry,
      Source::URL::Instagram,
      Source::URL::Lofter,
      Source::URL::Mastodon,
      Source::URL::Moebooru,
      Source::URL::NicoSeiga,
      Source::URL::Nijie,
      Source::URL::Newgrounds,
      Source::URL::PixivSketch,
      Source::URL::Plurk,
      Source::URL::Skeb,
      Source::URL::Tinami,
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

    # The name of the site this URL belongs to.
    #
    # @return [String]
    def site_name
      # XXX should go in dedicated subclasses.
      case host
      when /ask\.fm\z/i
        "Ask.fm"
      when /bcy\.net\z/i
        "BCY"
      when /booth\.pm\z/i
        "Booth.pm"
      when /circle\.ms\z/i
        "Circle.ms"
      when /dlsite\.(com|net)\z/i
        "DLSite"
      when /doujinshi\.mugimugi\.org\z/i
        "Doujinshi.org"
      when /fc2\.com\z/i
        "FC2"
      when /ko-fi\.com\z/i
        "Ko-fi"
      when /mixi\.jp\z/i
        "Mixi.jp"
      when /piapro\.jp\z/i
        "Piapro.jp"
      when /sakura\.ne\.jp\z/i
        "Sakura.ne.jp"
      else
        if self.class == Source::URL
          # "www.melonbooks.co.jp" => "Melonbooks"
          parsed_domain.sld.titleize
        else
          # "Source::URL::NicoSeiga" => "Nico Seiga"
          self.class.name.demodulize.titleize
        end
      end
    end

    # Convert the current URL into a profile URL, or return nil if it's not
    # possible to get the profile URL from the current URL.
    #
    # URLs in artist entries will be normalized into this form.
    #
    # Some sites may have multiple profile URLs, for example if the site has
    # both usernames and user IDs. This may return different profile URLs,
    # depending on whether the current URL has the username or the user ID.
    #
    # Examples:
    #
    # * https://www.pixiv.net/member.php?id=9948
    # * https://www.pixiv.net/stacc/bkubb
    # * https://twitter.com/bkub_comic
    # * https://twitter.com/intent/user?user_id=889592953
    #
    # @return [String, nil]
    def profile_url
      nil
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
