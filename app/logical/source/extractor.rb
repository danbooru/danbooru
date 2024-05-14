# frozen_string_literal: true

# A source extractor is used to extract information from a given source URL. It
# extracts all the images and videos from the URL, as well as metadata such as
# the tags, commentary, artist name, profile URL, and additional names and URLs
# for new artist entries.
#
# To add a new site, create a subclass of Source::Extractor and implement the following methods:
#
# * image_urls - The list of images or videos at this URL. Used during uploads.
# * page_url - The page containing the images. Used for post sources.
# * profile_url - The URL of the artist's profile page. Used for artist finding.
# * profile_urls - Extra profile URLs to add to the artist entry.
# * tag_name - The artist's login name. Used as the default name for new artist tags.
# * artist_name - The artist's display name. Used as an other name in new artist entries.
# * other_names - Extra names used in new artist entries.
# * tags - The artist's tags for the work. Used by translated tags.
# * artist_commentary_title - The artist's title of the work. Used for artist commentaries.
# * artist_commentary_desc - The artist's description of the work. Used for artist commentaries.
#
module Source
  class Extractor
    extend Memoist

    # The http timeout to download a file.
    DOWNLOAD_TIMEOUT = 60

    attr_reader :url, :referer_url, :parsed_url, :parsed_referer, :parent_extractor

    delegate :site_name, to: :parsed_url

    # Should return true if the extractor is configured correctly. Return false
    # if the extractor requires api keys that have not been configured.
    def self.enabled?
      true
    end

    # Return the extractor for the given `url`. The `url` may be either a
    # direct image URL, or the URL of a page containing one or more images.
    #
    # The `referer_url` is optionally provided when uploading direct image URLs
    # with the bookmarklet. This will be the page containing the image. This
    # lets us extract information from sites like Twitter, where the image URL by
    # itself doesn't have enough information to find the page containing the image.
    #
    # @param url [String] The URL to extract information from.
    # @param referer_url [String, nil] The page URL if `url` is an image URL.
    # @param default_extractor [Source::Extractor, nil] The extractor to use if no other extractor is found for this URL.
    # @param parent_extractor [Source::Extractor, nil] The parent of this extractor, if this is a sub extractor.
    # @return [Source::Extractor, nil] The extractor, or nil if the URL couldn't be parsed and the default extractor is nil.
    def self.find(url, referer_url = nil, default_extractor: Extractor::Null, parent_extractor: nil)
      parsed_url = Source::URL.parse(url)
      parsed_referer = Source::URL.parse(referer_url)
      parsed_url&.extractor(referer_url: parsed_referer, parent_extractor:) || default_extractor&.new(url, referer_url: referer_url, parent_extractor:)
    end

    # Initialize an extractor. Normally one should call `Source::Extractor.find`
    # instead of instantiating an extractor directly.
    #
    # @param url [Source::URL, String] The URL to extract information form.
    # @param referer_url [Source::URL, String, nil] The page URL if `url` is an image URL.
    # @param parent_extractor [Source::Extractor, nil] The parent of this extractor, if this is a sub extractor.
    def initialize(url, referer_url: nil, parent_extractor: nil)
      @url = url.to_s
      @referer_url = referer_url&.to_s
      @parent_extractor = parent_extractor

      @parsed_url = Source::URL.parse(url)
      @parsed_referer = Source::URL.parse(referer_url) if referer_url.present?
      @parsed_referer = nil if !allow_referer?
    end

    # Normally if the main URL and the referer URL are from two different sites, then we ignore the referer URL. For
    # example, a Twitter image URL with a Pixiv referer URL will ignore the Pixiv referer, because the Twitter image
    # doesn't belong to a Pixiv post. This allows this behavior to be overidden for extractors that allow referers from
    # other sites (see Source::Extractor::Google).
    def allow_referer?
      parsed_url&.image_url? && parsed_referer&.extractor_class == self.class
    end

    # The list of input URLs. Includes both the primary URL and the secondary referer URL, if it exists.
    def parsed_urls
      [parsed_url, parsed_referer].compact
    end

    # The list of image (or video) URLs extracted from the target URL.
    #
    # If the target URL is a page, this should be every image on the page. If
    # the target URL is a single image, this should be the image itself.
    #
    # @return [Array<String>]
    def image_urls
      []
    end

    # The URL of the page containing the image, or nil if it can't be found.
    #
    # The source of the post will be set to the page URL if it's not possible
    # to convert the image URL to a page URL for this site.
    #
    # For example, for sites like Twitter and Tumblr, it's not possible to
    # convert image URLs to page URLs, so the page URL will be used as the
    # source for these sites. For sites like Pixiv and DeviantArt, it is
    # possible to convert image URLs to page URLs, so the image URL will be
    # used as the source for these sites. This is determined by whether
    # `Source::URL#page_url` returns a URL or nil.
    #
    # @return [String, nil]
    def page_url
      nil
    end

    # A name to suggest as the artist's tag name when creating a new artist.
    # This should usually be the artist's login name. It should be plain ASCII,
    # hopefully unique, and it should follow the rules for tag names (see
    # TagNameValidator).
    #
    # @return [String, nil]
    def tag_name
      Tag.normalize_name(artist_name) if artist_name.present? && artist_name.match?(/\A[a-zA-Z0-9._-]+\z/)
    end

    # The artists's primary name. If an artist has both a display name and a
    # login name, this should be the display name. This will be used as an
    # other name for new artist entries.
    #
    # @return [String, nil]
    def artist_name
      nil
    end

    # A list of all names associated with the artist. These names will be suggested
    # as other names when creating a new artist.
    #
    # @return [Array<String>]
    def other_names
      [artist_name, tag_name].compact.uniq
    end

    # A link to the artist's profile page on the site. This will be used for
    # artist finding purposes, so it needs to match the URL in the artist entry.
    #
    # @return [String, nil]
    def profile_url
      nil
    end

    # A list of all profile urls associated with the artist. These urls will
    # be suggested when creating a new artist.
    #
    # @return [Array<String>]
    def profile_urls
      [profile_url].compact
    end

    # The artist's title of the work. Used for the artist commentary.
    #
    # @return [String, nil]
    def artist_commentary_title
      nil
    end

    # The artist's description of the work. Used for the artist commentary.
    #
    # @return [String, nil]
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
      Danbooru::Http.external
    end

    # A http client for downloading files.
    def http_downloader
      http.timeout(DOWNLOAD_TIMEOUT).max_size(Danbooru.config.max_file_size).use(:spoof_referrer).use(:unpolish_cloudflare)
    end

    # Find the artist(s) associated with this source URL. For known sites (e.g., art platforms shared by many artists),
    # we extract the profile URL(s) and look for artist entries with a matching profile URL. For URLs from unknown sites
    # (e.g., personal artist websites), we look for a prefix match of the URL (that is, we look for artist URLs that are
    # from the same site and that have the same subfolders).
    #
    # @return [ActiveRecord::Relation<Artist>]
    def artists
      if parsed_url&.profile_url?
        Artist.active.has_normalized_url([parsed_url.profile_url])
      elsif parsed_url&.recognized?
        Artist.active.has_normalized_url(profile_urls)
      else
        ArtistFinder.find_artists(url)
      end
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
      translated_tags = normalized_tags.flat_map(&method(:translate_tag)).uniq
      translated_tags = translated_tags.reject(&:artist?).reject(&:is_deprecated?)

      translated_tags.sort_by do |tag|
        [TagCategory.categorized_list.index(tag.category_name.downcase), tag.name]
      end
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
      "source:#{url}"
    end

    def related_posts(limit = 5)
      Post.system_tag_match(related_posts_search_query).paginate(1, limit: limit)
    end

    # A hash containing the results of any API calls made by the extractor. For debugging purposes only.
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
        :tags => tags,
        :normalized_tags => normalized_tags,
        :translated_tags => translated_tags,
        :artist_commentary => {
          :title => artist_commentary_title,
          :description => artist_commentary_desc,
          :dtext_title => dtext_artist_commentary_title,
          :dtext_description => dtext_artist_commentary_desc
        },
        :api_response => api_response
      }
    end

    def to_json(*_args)
      to_h.to_json
    end

    def http_exists?(url)
      return false if url.blank?
      http_downloader.head(url).status.success?
    end

    # @return [Enumerator] An enumerator that lets you iterate across the chain of parent extractors.
    def each_parent
      return enum_for(:each_parent) unless block_given?

      parent = parent_extractor
      while parent.present?
        yield parent
        parent = parent.parent_extractor
      end
    end

    # @return [Array<Source::Extractor>] Return the list of parent extractors.
    def parent_extractors
      each_parent.to_a
    end

    # Convert commentary to dtext by stripping html tags. Sites can override
    # this to customize how their markup is translated to dtext.
    def self.to_dtext(text)
      text = text.to_s
      text = Rails::Html::FullSanitizer.new.sanitize(text, encode_special_chars: false)
      text = CGI.unescapeHTML(text)
      text.strip
    end

    memoize :http, :http_downloader, :related_posts
  end
end
