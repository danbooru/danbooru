# This is a collection of strategies for extracting information about a 
# resource. At a minimum it tries to extract the artist name and a canonical 
# URL to download the image from. But it can also be used to normalize a URL 
# for use with the artist finder. It differs from Downloads::RewriteStrategies
# in that the latter is more for normalizing and rewriting a URL until it is 
# suitable for downloading, whereas Sources::Strategies is more for meta-data 
# that can only be obtained by downloading and parsing the resource.

module Sources
  module Strategies
    class Base
      attr_reader :url, :referer_url
      attr_reader :artist_name, :profile_url, :image_url, :tags, :page_count
      attr_reader :artist_commentary_title, :artist_commentary_desc

      def self.url_match?(url)
        false
      end

      def initialize(url, referer_url = nil)
        @url = url
        @referer_url = referer_url
        @page_count = 1
      end

      # No remote calls are made until this method is called.
      def get
        raise NotImplementedError
      end

      def get_size
        @get_size ||= Downloads::File.new(@image_url).size
      end

      # Subclasses should return true only if the URL is in its final normalized form.
      #
      # Sources::Site.new("http://img.pixiv.net/img/evazion").normalized_for_artist_finder?
      # => true
      # Sources::Site.new("http://i2.pixiv.net/img18/img/evazion/14901720_m.png").normalized_for_artist_finder?
      # => false
      def normalized_for_artist_finder?
        false
      end

      # Subclasses should return true only if the URL is a valid URL that could
      # be converted into normalized form.
      #
      # Sources::Site.new("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=18557054").normalizable_for_artist_finder?
      # => true
      # Sources::Site.new("http://dic.pixiv.net/a/THUNDERproject").normalizable_for_artist_finder?
      # => false
      def normalizable_for_artist_finder?
        false
      end

      def normalize_for_artist_finder!
        url
      end

      def site_name
        raise NotImplementedError
      end

      def unique_id
        artist_name
      end

      def artist_record
        if artist_name.present?
          Artist.other_names_match(artist_name)
        else
          nil
        end
      end

      def image_urls
        [image_url]
      end

      def tags
        (@tags || []).uniq
      end

      # Should be set to a url for sites that prevent hotlinking, or left nil for sites that don't.
      def fake_referer
        nil
      end

      def dtext_artist_commentary_title
        self.class.to_dtext(artist_commentary_title)
      end

      def dtext_artist_commentary_desc
        self.class.to_dtext(artist_commentary_desc)
      end

    protected
      def agent
        raise NotImplementedError
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
