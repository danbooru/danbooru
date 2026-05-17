# frozen_string_literal: true

# A Source::URL is a URL from a source site, such as Twitter, Pixiv, etc. Each site has a
# subclass responsible for parsing and extracting information from URLs for that site.
#
# Source::Extractors are the main user of Source::URLs. Each Source::URL subclass usually
# has a corresponding extractor for extracting data from that site.
#
# To add a new site, create a subclass of Source::URL and implement `#match?` to define
# which URLs belong to the site, and `#parse` to parse and extract information from the URL.
# Use `site` to define which site(s) are supported by the class.
#
# The following methods should be implemented by subclasses:
#
# * match?
# * parse
# * image_url?
# * page_url
# * profile_url
# * source_site (if the class supports more than one site)
# * extractor_class (if the class has multiple possible extractors)
# * self.extractors (if the class has multiple possible extractors)
#
# Source::URL is a subclass of Danbooru::URL, so it inherits some common utility methods
# from there.
#
# @example
#   url = Source::URL.parse("https://x.com/yasunavert/status/1496123903290314755")
#   url.site_name        # => "Twitter"
#   url.status_id        # => "1496123903290314755"
#   url.username         # => "yasunavert"
#
# @see Danbooru::URL
module Source
  class URL < Danbooru::URL
    # @return [Array<Source::Site>] The list of sites handled by this class.
    class_attribute :sites

    # True if all URL subclasses have been loaded and don't need to be loaded again.
    class_attribute :subclasses_loaded, default: false

    # The autoloader used to load Source::URL subclasses.
    class_attribute :autoloader, default: Zeitwerk::Loader

    # A macro that defines a new site with the given name and options.
    def self.site(name, **options, &block)
      self.sites ||= []
      self.sites << Site.new(name: name, url_class: self, **options, &block)
    end

    # A macro that defines the list of extractors used by an URL class, if the class can use multiple extractors. Usage:
    #
    #   extractors { [Source::Extractor::Reddit, Source::Extractor::RedditComment] }
    #
    # Most sites only have one extractor, which has the same name as the URL class (e.g. Source::URL::Pixiv ->
    # Source::Extractor::Pixiv). For sites like Reddit or Ko-fi, which have multiple extractors for different URLs, this
    # is used to set the list of all possible extractors used by a site.
    #
    # When called with a block, this sets the list of extractors. When not called with a block, it returns them.
    #
    # @return [Array<Source::Extractor>] The extractor classes used by this URL class.
    def self.extractors(&block)
      if block_given?
        define_singleton_method(:extractors, &block) # redefine this method to return the list of extractors
      else
        ["Source::Extractor::#{name.demodulize}".safe_constantize].compact
      end
    end

    # Parse a URL into a subclass of Source::URL, or raise an exception if the URL is not a valid HTTP or HTTPS URL.
    #
    # @param url [String, Danbooru::URL]
    # @return [Source::URL]
    def self.parse!(url)
      return url if url.is_a?(Source::URL)

      url = Danbooru::URL.parse!(url)
      subclass = Source::Site.find_by_domain(url.domain).find { |site| site.url_class.match?(url) }&.url_class
      subclass = url_subclasses.find { |subclass| subclass.match?(url) } if subclass.nil?
      subclass = Source::URL::Null if subclass.nil?
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

    # @return [Array<Source::URL>] The set of Source::URL subclasses. Loaded lazily on demand.
    def self.url_subclasses
      self.subclasses_loaded ||= autoloader&.eager_load_namespace(Source::URL).present?
      Source::URL.descendants.excluding(Source::URL::Null)
    end

    # @return [Source::Extractor, nil] The extractor class to use for this URL. By default, it's the Source::Extractor subclass
    #   with the same name as this Source::URL subclass. Subclasses can override this to use different extractors for different URLs.
    def extractor_class
      self.class.extractors.sole if self.class.extractors.one?
    end

    # Return the extractor corresponding to this URL.
    #
    # @param options [Hash] The options to pass to the extractor.
    # @return [Source::Extractor, nil] The extractor for this URL, or nil if one doesn't exist.
    def extractor(**)
      extractor_class&.new(self, **)
    end

    # @return [Source::Site, nil] The site this URL belongs to. May be overridden if the URL class handles multiple
    # sites. By default, if there are multiple sites it chooses the site with the same domain.
    def source_site
      if self.class.sites.one?
        self.class.sites.sole
      else
        sites = Source::Site.find_by_domain(domain)
        sites.sole if sites.one?
      end
    end

    # @return [String, nil] # The name of the site this URL belongs to.
    def site_name
      source_site&.name
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
    # * https://x.com/motty08111213/status/943446161586733056
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
    # * https://x.com/bkub_comic
    #
    # @return [Boolean]
    def profile_url?
      profile_url.present? && !page_url? && !image_url?
    end

    # True if the URL is a secondary profile page URL.
    # A secondary URL is an artist URL that we don't normally want to display,
    # usually because it's redundant with the primary profile URL.
    #
    # Examples:
    #
    # * https://www.pixiv.net/stacc/bkubb
    # * https://x.com/i/889592953
    #
    # @return [Boolean]
    def secondary_url?
      false
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
    # * https://x.com/bkub_comic
    # * https://x.com/i/user/889592953
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

    # Determine if the URL is considered an "image sample".
    #
    # @return [Boolean, nil] True if the URL is an image sample, false if it's not an image sample, or nil if we don't know
    #   whether it's an image sample or not.
    def image_sample?
      nil
    end

    def self.site_name(url)
      Source::URL.parse(url)&.site_name
    end

    def self.image_url?(url)
      Source::URL.parse(url)&.image_url?
    end

    def self.image_sample?(url)
      Source::URL.parse(url)&.image_sample?
    end

    def self.page_url?(url)
      Source::URL.parse(url)&.page_url?
    end

    def self.profile_url?(url)
      Source::URL.parse(url)&.profile_url?
    end

    def self.secondary_url?(url)
      Source::URL.parse(url)&.secondary_url?
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
      super
      parse
    end

    # Subclasses should implement this to parse and extract any useful information from
    # the URL. This is called when the URL is initialized.
    protected def parse
    end

    def inspect
      variables = instance_values.without("url").reject { |key, _| key.starts_with?("_memoized") }.compact_blank
      state = variables.map { |name, value| "@#{name}=#{value.inspect}" }.join(" ")
      "#<#{self.class.name} #{state}>"
    end
  end
end
