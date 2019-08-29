# This is a collection of strategies for extracting information about a 
# resource. At a minimum it tries to extract the artist name and a canonical 
# URL to download the image from. But it can also be used to normalize a URL 
# for use with the artist finder. 
#
# Design Principles
#
# In general you should minimize state. You can safely assume that <tt>url</tt>
# and <tt>referer_url</tt> will not change over the lifetime of an instance,
# so you can safely memoize methods and their results. A common pattern is
# conditionally making an external API call and parsing its response. You should
# make this call on demand and memoize the response.

module Sources
  module Strategies
    class Base
      attr_reader :url, :referer_url, :urls, :parsed_url, :parsed_referer, :parsed_urls

      extend Memoist

      # Should return true if all prerequisites for using the strategy are met.
      # Return false if the strategy requires api keys that have not been configured.
      def self.enabled?
        true
      end

      # * <tt>url</tt> - Should point to a resource suitable for 
      #   downloading. This may sometimes point to the binary file. 
      #   It may also point to the artist's profile page, in cases
      #   where this class is being used to normalize artist urls.
      #   Implementations should be smart enough to detect this and 
      #   behave accordingly.
      # * <tt>referer_url</tt> - Sometimes the HTML page cannot be
      #   determined from <tt>url</tt>. You should generally pass in a
      #   <tt>referrer_url</tt> so the strategy can discover the HTML
      #   page and other information.
      def initialize(url, referer_url = nil)
        @url = url
        @referer_url = referer_url
        @urls = [url, referer_url].select(&:present?)

        @parsed_url = Addressable::URI.heuristic_parse(url) rescue nil
        @parsed_referer = Addressable::URI.heuristic_parse(referer_url) rescue nil
        @parsed_urls = [parsed_url, parsed_referer].select(&:present?)
      end

      # Should return true if this strategy should be used. By default, checks
      # if the main url belongs to any of the domains associated with this site.
      def match?
        return false if parsed_url.nil?
        parsed_url.domain.in?(domains)
      end

      # The list of base domains belonging to this site. Subdomains are
      # automatically included (i.e. "pixiv.net" matches "fanbox.pixiv.net").
      def domains
        []
      end

      def site_name
        Addressable::URI.heuristic_parse(url).host
      rescue Addressable::URI::InvalidURIError => e
        nil
      end

      # Whatever <tt>url</tt> is, this method should return the direct links 
      # to the canonical binary files. It should not be an HTML page. It should 
      # be a list of JPEG, PNG, GIF, WEBM, MP4, ZIP, etc. It is what the 
      # downloader will fetch and save to disk.
      def image_urls
        raise NotImplementedError
      end

      def image_url
        image_urls.first
      end

      # A smaller representation of the image that's suitable for
      # displaying previews.
      def preview_urls
        image_urls
      end

      def preview_url
        preview_urls.first
      end

      # Whatever <tt>url</tt> is, this method should return a link to the HTML
      # page containing the resource. It should not be a binary file. It will
      # eventually be assigned as the source for the post, but it does not
      # represent what the downloader will fetch.
      def page_url
        Rails.logger.warn "Valid page url for (#{url}, #{referer_url}) not found"

        return nil
      end

      # This will be the url stored in posts. Typically this is the page
      # url, but on some sites it may be preferable to store the image url.
      def canonical_url
        page_url || image_url
      end

      # A name to suggest as the artist's tag name when creating a new artist.
      # This should usually be the artist's account name.
      def tag_name
        artist_name
      end

      # The artists's primary name. If an artist has both a display name and an
      # account name, this should be the display name.
      def artist_name
        nil
      end

      # A list of all names associated with the artist. These names will be suggested
      # as other names when creating a new artist.
      def other_names
        [artist_name, tag_name].compact.uniq
      end

      # A link to the artist's profile page on the site.
      def profile_url
        nil
      end

      # A list of all profile urls associated with the artist. These urls will
      # be suggested when creating a new artist.
      def profile_urls
        [normalize_for_artist_finder]
      end

      def artist_commentary_title
        nil
      end

      def artist_commentary_desc
        nil
      end

      # Subclasses should merge in any required headers needed to access resources
      # on the site.
      def headers
        return Danbooru.config.http_headers
      end

      # Returns the size of the image resource without actually downloading the file.
      def size
        Downloads::File.new(image_url).size
      end
      memoize :size

      # Subclasses should return true only if the URL is in its final normalized form.
      #
      # Sources::Strategies.find("http://img.pixiv.net/img/evazion").normalized_for_artist_finder?
      # => true
      # Sources::Strategies.find("http://i2.pixiv.net/img18/img/evazion/14901720_m.png").normalized_for_artist_finder?
      # => false
      def normalized_for_artist_finder?
        false
      end

      # Subclasses should return true only if the URL is a valid URL that could
      # be converted into normalized form.
      #
      # Sources::Strategies.find("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054").normalizable_for_artist_finder?
      # => true
      # Sources::Strategies.find("http://dic.pixiv.net/a/THUNDERproject").normalizable_for_artist_finder?
      # => false
      def normalizable_for_artist_finder?
        normalize_for_artist_finder.present?
      end

      # The url to use for artist finding purposes. This will be stored in the
      # artist entry. Normally this will be the profile url.
      def normalize_for_artist_finder
        profile_url.presence || url
      end

      def artists
        Artist.find_artists(normalize_for_artist_finder.to_s)
      end

      # A new artist entry with suggested defaults for when the artist doesn't
      # exist. Used in Artist.new_with_defaults to prefill the new artist form.
      def new_artist
        Artist.new(
          name: tag_name,
          other_names: other_names,
          url_string: profile_urls.join("\n")
        )
      end

      def file_url
        image_url
      end

      def data
        {}
      end

      def tags
        (@tags || []).uniq
      end

      def normalized_tags
        tags.map { |tag, url| normalize_tag(tag) }.sort.uniq
      end

      def normalize_tag(tag)
        WikiPage.normalize_other_name(tag).downcase
      end

      def translated_tags
        translated_tags = normalized_tags.flat_map(&method(:translate_tag)).uniq.sort
        translated_tags.reject { |tag| tag.category == Tag.categories.artist }
      end

      # Given a tag from the source site, should return an array of corresponding Danbooru tags.
      def translate_tag(untranslated_tag)
        return [] if untranslated_tag.blank?

        translated_tag_names = WikiPage.active.other_names_include(untranslated_tag).uniq.pluck(:title)
        translated_tag_names = TagAlias.to_aliased(translated_tag_names)
        translated_tags = Tag.where(name: translated_tag_names)

        if translated_tags.empty?
          normalized_name = TagAlias.to_aliased([Tag.normalize_name(untranslated_tag)])
          translated_tags = Tag.nonempty.where(name: normalized_name)
        end

        translated_tags
      end

      def dtext_artist_commentary_title
        self.class.to_dtext(artist_commentary_title)
      end

      def dtext_artist_commentary_desc
        self.class.to_dtext(artist_commentary_desc)
      end

      # A strategy may return extra data unrelated to the file
      def data
        return {}
      end

      # A search query that should return any posts that were previously
      # uploaded from the same source. These may be duplicates, or they may be
      # other posts from the same gallery.
      def related_posts_search_query
        "source:#{canonical_url}"
      end

      def related_posts(limit = 5)
        CurrentUser.as_system { Post.tag_match(related_posts_search_query).paginate(1, limit: limit) }
      end
      memoize :related_posts

      # A hash containing the results of any API calls made by the strategy. For debugging purposes only.
      def api_response
        nil
      end

      def to_h
        return {
          :artist => {
            :name => artist_name,
            :tag_name => tag_name,
            :other_names => other_names,
            :profile_url => profile_url,
            :profile_urls => profile_urls,
          },
          :artists => artists.as_json(include: :sorted_urls),
          :image_url => image_url,
          :image_urls => image_urls,
          :page_url => page_url,
          :canonical_url => canonical_url,
          :normalized_for_artist_finder_url => normalize_for_artist_finder,
          :tags => tags,
          :normalized_tags => normalized_tags,
          :translated_tags => translated_tags,
          :artist_commentary => {
            :title => artist_commentary_title,
            :description => artist_commentary_desc,
            :dtext_title => dtext_artist_commentary_title,
            :dtext_description => dtext_artist_commentary_desc,
          },
          :api_response => api_response.to_h,
        }
      end

      def to_json
        to_h.to_json
      end

    protected

      def http_exists?(url, headers)
        res = HTTParty.head(url, Danbooru.config.httparty_options.deep_merge(headers: headers))
        res.success?
      end

      # Convert commentary to dtext by stripping html tags. Sites can override
      # this to customize how their markup is translated to dtext.
      def self.to_dtext(text)
        text = text.to_s
        text = Rails::Html::FullSanitizer.new.sanitize(text, encode_special_chars: false)
        text = CGI::unescapeHTML(text)
        text
      end
    end
  end
end
