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
      Source::URL::Bilibili,
      Source::URL::Rule34DotUs,
      Source::URL::FourChan,
      Source::URL::Picdig,
      Source::URL::Enty,
      Source::URL::ArcaLive,
      Source::URL::Imgur,
      Source::URL::Zerochan,
      Source::URL::Poipiku,
      Source::URL::AboutMe,
      Source::URL::ArtStreet,
      Source::URL::Gumroad,
      Source::URL::Misskey,
      Source::URL::Xfolio,
      Source::URL::CiEn,
      Source::URL::Inkbunny,
      Source::URL::E621,
      Source::URL::Bluesky,
      Source::URL::Danbooru2,
      Source::URL::Pinterest,
      Source::URL::Foriio,
      Source::URL::Itaku,
      Source::URL::Postype,
      Source::URL::Artistree,
      Source::URL::Galleria,
      Source::URL::Dotpict,
      Source::URL::Discord,
      Source::URL::Opensea,
      Source::URL::Behance,
      Source::URL::Cohost,
      Source::URL::Piapro,
      Source::URL::MyPortfolio,
      Source::URL::Note,
      Source::URL::PixivComic,
      Source::URL::NaverBlog,
      Source::URL::NaverCafe,
      Source::URL::NaverPost,
      Source::URL::Xiaohongshu,
      Source::URL::Patreon,
      Source::URL::Blogger,
      Source::URL::Vk,
      Source::URL::Google,
      Source::URL::Youtube,
      Source::URL::Bcy,
      Source::URL::URLShortener,
      Source::URL::Redgifs,
      Source::URL::Carrd,
      Source::URL::Toyhouse,
      Source::URL::Skland,
    ]

    # Parse a URL into a subclass of Source::URL, or raise an exception if the URL is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Source::URL]
    def self.parse!(url)
      return url if url.is_a?(Source::URL)

      url = Danbooru::URL.parse!(url)
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

    # Return the extractor class to use for this URL. By default, it's the Source::Extractor subclass with the same name
    # as this Source::URL subclass. Subclasses can override this to provide a different extractor.
    def extractor_class
      "Source::Extractor::#{self.class.name.demodulize}".safe_constantize
    end

    # Return the extractor corresponding to this URL.
    #
    # @param options [Hash] The options to pass to the extractor.
    # @return [Source::Extractor, nil] The extractor for this URL, or nil if one doesn't exist.
    def extractor(**options)
      extractor_class&.new(self, **options)
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
      file_ext.to_s.downcase.in?(%w[jpg jpeg png gif webp webm avif mp4 swf flac mp3 ogg wav])
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

    # Determine if the URL is considered a "bad source". A bad source is an URL that should never be used as the source of a
    # post because it's never a valid source. For example, a profile URL or some other random URL that isn't a page URL
    # or an image URL.
    #
    # Posts will be tagged "bad_source" if this returns true for the post's source URL. If this returns false, then the
    # bad_source tag will be removed. If this returns nil, then the bad_source tag will not be added or removed.
    #
    # @return [Boolean, nil] True if the URL is a bad source, false if it's not a bad source, or nil if we don't know
    #   whether it's a bad source or not.
    def bad_source?
      recognized? && !image_url? && !page_url?
    end

    # Determine if the URL is considered a "bad link". A bad link is an image URL that shouldn't be used as the source of a
    # post. For example, Twitter image URLs are bad links because it's not possible to convert Twitter image URLs to the
    # actual Twitter post. A Pixiv image URL is a good link because it is possible to convert Pixiv image URLs to the
    # actual Pixiv post.
    #
    # Posts will be tagged "bad_link" if this returns true for the post's source URL. If this returns false, then the
    # bad_link tag will be removed. If this returns nil, then the bad_link tag will not be added or removed.
    #
    # @return [Boolean, nil] True if the URL is a bad link, false if it's not a bad link, or nil if we don't know
    #   whether it's a bad link or not.
    def bad_link?
      recognized? && image_url? && page_url.nil?
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

    def self.bad_link?(url)
      Source::URL.parse(url)&.bad_link?
    end

    def self.bad_source?(url)
      Source::URL.parse(url)&.bad_source?
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
