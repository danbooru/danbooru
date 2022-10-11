# frozen_string_literal: true

# A Source::URL is a URL from a source site, such as Twitter, Pixiv, etc. Each site has a
# subclass responsible for parsing and extracting information from URLs for that site.
#
# Source::Extractors are the main user of Source::URLs. Each Source::URL subclass usually
# has a corresponding extractor for extracting data from that site.
#
# To add a new site, create a subclass of Source::URL and implement `#match?` to define
# which URLs belong to the site, and `#parse` to parse and extract information from the URL.
#
# The following methods should be implemented by subclasses:
#
# * match?
# * parse
# * image_url?
# * page_url
# * profile_url
#
# Source::URL is a subclass of Danbooru::URL, so it inherits some common utility methods
# from there.
#
# @example
#   url = Source::URL.parse("https://twitter.com/yasunavert/status/1496123903290314755")
#   url.site_name        # => "Twitter"
#   url.status_id        # => "1496123903290314755"
#   url.username         # => "yasunavert"
#
# @see Danbooru::URL
module Source
  class URL < Danbooru::URL
    SUBCLASSES = [
      Source::URL::Pixiv,
      Source::URL::Twitter,
      Source::URL::ArtStation,
      Source::URL::Booth,
      Source::URL::DeviantArt,
      Source::URL::Fanbox,
      Source::URL::Fandom,
      Source::URL::Fantia,
      Source::URL::Fc2,
      Source::URL::Foundation,
      Source::URL::Gelbooru,
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
      Source::URL::Reddit,
      Source::URL::Skeb,
      Source::URL::Tinami,
      Source::URL::Tumblr,
      Source::URL::TwitPic,
      Source::URL::Weibo,
      Source::URL::Anifty,
      Source::URL::Furaffinity,
    ]

    # Parse a URL into a subclass of Source::URL, or raise an exception if the URL is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Source::URL]
    def self.parse!(url)
      url = Danbooru::URL.new(url)
      subclass = SUBCLASSES.find { |c| c.match?(url) } || Source::URL::Null
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
      # "Source::URL::NicoSeiga" => "Nico Seiga"
      self.class.name.demodulize.titleize
    end

    # True if the URL is from a recognized site. False if the URL is from an unrecognized site.
    #
    # @return [Boolean]
    def recognized?
      true # overridden in Source::URL::Null to return false for unknown sites
    end

    # True if the URL is a direct image URL.
    #
    # Examples:
    #
    # * https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
    # * https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
    # * https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig
    #
    # @return [Boolean]
    def image_url?
      file_ext.in?(%w[jpg jpeg png gif webp webm mp4 swf])
    end

    # True if the URL is a work page URL.
    #
    # Examples:
    #
    # * https://www.pixiv.net/artworks/46324488
    # * https://twitter.com/motty08111213/status/943446161586733056
    #
    # @return [Boolean]
    def page_url?
      page_url.present? && !image_url?
    end

    # True if the URL is a profile page URL.
    #
    # Examples:
    #
    # * https://www.pixiv.net/users/9948
    # * https://twitter.com/intent/user?user_id=889592953
    #
    # @return [Boolean]
    def profile_url?
      profile_url.present? && !page_url? && !image_url?
    end

    # Convert an image URL to the URL of the page containing the image, or
    # return nil if it's not possible to convert the current URL to a page URL.
    #
    # When viewing a post, the source will be shown as the page URL if it's
    # possible to convert the source from an image URL to a page URL.
    #
    # When uploading a post, the source will be set to the image URL if the
    # image URL is convertible to a page URL. Otherwise, it's set to the page URL.
    #
    # Examples:
    #
    # * https://i.pximg.net/img-original/img/2014/10/03/18/10/20/46324488_p0.png
    #   => https://www.pixiv.net/artworks/46324488
    #
    # * https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/intermediary/f/8b472d70-a0d6-41b5-9a66-c35687090acc/d23jbr4-8a06af02-70cb-46da-8a96-42a6ba73cdb4.jpg/v1/fill/w_786,h_1017,q_70,strp/silverhawks_quicksilver_by_edsfox_d23jbr4-pre.jpg
    #   => https://www.deviantart.com/edsfox/art/Silverhawks-Quicksilver-126872896
    #
    # * https://pbs.twimg.com/media/EBGbJe_U8AA4Ekb.jpg:orig
    #   => nil
    #
    # @return [String, nil]
    def page_url
      nil
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

    def self.site_name(url)
      Source::URL.parse(url)&.site_name
    end

    def self.image_url?(url)
      Source::URL.parse(url)&.image_url?
    end

    def self.page_url?(url)
      Source::URL.parse(url)&.page_url?
    end

    def self.profile_url?(url)
      Source::URL.parse(url)&.profile_url?
    end

    def self.page_url(url)
      Source::URL.parse(url)&.page_url
    end

    def self.profile_url(url)
      Source::URL.parse(url)&.profile_url
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
