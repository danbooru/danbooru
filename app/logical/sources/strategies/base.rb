# frozen_string_literal: true

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
      extend Memoist

      # The http timeout to download a file.
      DOWNLOAD_TIMEOUT = 60

      attr_reader :url, :referer_url, :parsed_url, :parsed_referer
      delegate :site_name, to: :parsed_url

      # Should return true if all prerequisites for using the strategy are met.
      # Return false if the strategy requires api keys that have not been configured.
      def self.enabled?
        true
      end

      # Extract information from a target URL. The target URL may be either a
      # direct image URL, or the URL of a HTML page containing one or more
      # images.
      #
      # The referer URL is optionally provided when uploading direct image URLs
      # with the bookmarklet. This lets us find the page containing the image
      # for sites like Twitter, where the image URL by itself doesn't have
      # enough information to find the page containing the image.
      #
      # @param url [String] The target URL
      # @param referer_url [String] If the the target URL is an image URL, this
      #   should be the HTML page containing the image.
      def initialize(url, referer_url = nil)
        @url = url.to_s
        @referer_url = referer_url&.to_s

        @parsed_url = Source::URL.parse(url)
        @parsed_referer = Source::URL.parse(referer_url) if referer_url.present?
        @parsed_referer = nil if parsed_url&.site_name != parsed_referer&.site_name
      end

      # Should return true if this strategy should be used. By default, checks
      # if the main url belongs to any of the domains associated with this site.
      def match?
        false
      end

      # Whatever <tt>url</tt> is, this method should return the direct links
      # to the canonical binary files. It should not be an HTML page. It should
      # be a list of JPEG, PNG, GIF, WEBM, MP4, ZIP, etc. It is what the
      # downloader will fetch and save to disk.
      def image_urls
        []
      end

      # Whatever <tt>url</tt> is, this method should return a link to the HTML
      # page containing the resource. It should not be a binary file. It will
      # eventually be assigned as the source for the post, but it does not
      # represent what the downloader will fetch.
      def page_url
        nil
      end

      # This will be the url stored in posts. Typically this is the page
      # url, but on some sites it may be preferable to store the image url.
      def canonical_url
        page_url || image_urls.first
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

      # A link to the artist's profile page on the site. This will be used for
      # artist finding purposes, so it needs to match the URL in the artist entry.
      def profile_url
        nil
      end

      # A list of all profile urls associated with the artist. These urls will
      # be suggested when creating a new artist.
      def profile_urls
        [profile_url].compact
      end

      def artist_commentary_title
        nil
      end

      def artist_commentary_desc
        nil
      end

      # Download the file at the given url. Raises Danbooru::Http::DownloadError if the download fails, or
      # Danbooru::Http::FileTooLargeError if the file is too large.
      #
      # @return [MediaFile] the downloaded file
      def download_file!(download_url)
        response, file = http_downloader.download_media(download_url)
        file
      end

      # A http client for API requests.
      def http
        Danbooru::Http.new.proxy.public_only
      end
      memoize :http

      # A http client for downloading files.
      def http_downloader
        http.timeout(DOWNLOAD_TIMEOUT).max_size(Danbooru.config.max_file_size).use(:spoof_referrer).use(:unpolish_cloudflare)
      end
      memoize :http_downloader

      def artists
        ArtistFinder.find_artists(profile_url)
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

      def tags
        (@tags || []).uniq
      end

      def normalized_tags
        tags.map { |tag, _url| normalize_tag(tag) }.sort.uniq
      end

      def normalize_tag(tag)
        WikiPage.normalize_other_name(tag).downcase
      end

      def translated_tags
        translated_tags = normalized_tags.flat_map(&method(:translate_tag)).uniq.sort
        translated_tags.reject(&:artist?)
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

      # A search query that should return any posts that were previously
      # uploaded from the same source. These may be duplicates, or they may be
      # other posts from the same gallery.
      def related_posts_search_query
        "source:#{canonical_url}"
      end

      def related_posts(limit = 5)
        Post.system_tag_match(related_posts_search_query).paginate(1, limit: limit)
      end
      memoize :related_posts

      # A hash containing the results of any API calls made by the strategy. For debugging purposes only.
      def api_response
        nil
      end

      def to_h
        {
          :artist => {
            :name => artist_name,
            :tag_name => tag_name,
            :other_names => other_names,
            :profile_url => profile_url,
            :profile_urls => profile_urls
          },
          :artists => artists.as_json(include: :sorted_urls),
          :image_urls => image_urls,
          :page_url => page_url,
          :canonical_url => canonical_url,
          :tags => tags,
          :normalized_tags => normalized_tags,
          :translated_tags => translated_tags,
          :artist_commentary => {
            :title => artist_commentary_title,
            :description => artist_commentary_desc,
            :dtext_title => dtext_artist_commentary_title,
            :dtext_description => dtext_artist_commentary_desc
          },
          :api_response => api_response.to_h
        }
      end

      def to_json(*_args)
        to_h.to_json
      end

      def http_exists?(url)
        http_downloader.head(url).status.success?
      end

      # Convert commentary to dtext by stripping html tags. Sites can override
      # this to customize how their markup is translated to dtext.
      def self.to_dtext(text)
        text = text.to_s
        text = Rails::Html::FullSanitizer.new.sanitize(text, encode_special_chars: false)
        text = CGI.unescapeHTML(text)
        text
      end
    end
  end
end
