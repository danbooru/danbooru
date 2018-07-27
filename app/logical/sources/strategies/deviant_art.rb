module Sources
  module Strategies
    class DeviantArt < Base
      extend Memoist

      def self.url_match?(url)
        url =~ /^https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/
      end

      def self.normalize(url)
        if url =~ %r{\Ahttps?://(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net/.+/[a-z0-9_]*_by_[a-z0-9_]+-d([a-z0-9]+)\.}i
          "http://fav.me/d#{$1}"
        elsif url =~ %r{\Ahttps?://(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net/.+/[a-f0-9]+-d([a-z0-9]+)\.}i
          "http://fav.me/d#{$1}"
        elsif url =~ %r{\Ahttps?://www\.deviantart\.com/([^/]+)/art/}
          url
        elsif url !~ %r{\Ahttps?://(?:fc|th|pre|orig|img|www)\.} && url =~ %r{\Ahttps?://(.+?)\.deviantart\.com(.*)}
          "http://www.deviantart.com/#{$1}#{$2}"
        else
          url
        end
      end

      def referer_url
        if @referer_url =~ /deviantart\.com\/art\// && @url =~ /https?:\/\/(?:fc|th|pre|orig|img)\d{2}\.deviantart\.net\//
          @referer_url
        else
          @url
        end
      end

      def site_name
        "Deviant Art"
      end

      def unique_id
        artist_name
      end

      def get
        # no-op
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc) do |element|
          # Convert embedded thumbnails of journal posts to 'deviantart #123'
          # links. Strip embedded thumbnails of image posts. Example:
          # https://sa-dui.deviantart.com/art/Commission-Meinos-Kaen-695905927.
          if element.name == "a" && element["data-sigil"] == "thumb"
            element.name = "span"

            # <a href="https://sa-dui.deviantart.com/journal/About-Commissions-223178193" data-sigil="thumb" class="thumb lit" ...>
            if element["class"].split.include?("lit")
              deviation_id = element["href"][%r!-(\d+)\z!, 1].to_i
              element.content = "deviantart ##{deviation_id}"
            else
              element.content = ""
            end
          end

          if element.name == "a" && element["href"].present?
            element["href"] = element["href"].gsub(%r!\Ahttps?://www\.deviantart\.com/users/outgoing\?!i, "")

            # href may be missing the `http://` bit (ex: `inprnt.com`, `//inprnt.com`). Add it if missing.
            uri = Addressable::URI.heuristic_parse(element["href"]) rescue nil
            if uri.present?
              uri.scheme ||= "http"
              element["href"] = uri.to_s
            end
          end
        end.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
      end

      def artist_name
        api_metadata.dig(:author, :username).try(&:downcase)
      end

      def profile_url
        return "" if artist_name.blank?
        "https://www.deviantart.com/#{artist_name}"
      end

      def image_url
        # work is deleted, use image url as given by user.
        if uuid.nil?
          url
        # work is downloadable
        elsif api_deviation[:is_downloadable] && api_deviation[:download_filesize] != api_deviation.dig(:content, :filesize)
          src = api_download[:src]
          src.gsub!(%r!\Ahttps?://s3\.amazonaws\.com/!i, "https://")
          src.gsub!(/\?.*\z/, "") # strip s3 query params
          src.gsub!(%r!\Ahttps://origin-orig\.deviantart\.net!, "http://origin-orig.deviantart.net") # https://origin-orig.devianart.net doesn't work

          src
        # work isn't downloadable, or download size is same as regular size.
        elsif api_deviation.present?
          api_deviation.dig(:content, :src)
        else
          raise "couldn't find image url"
        end
      end

      def tags
        return [] if api_metadata.blank?

        api_metadata[:tags].map do |tag|
          [tag[:tag_name], "https://www.deviantart.com/tag/#{tag[:tag_name]}"]
        end
      end

      def artist_commentary_title
        api_metadata[:title]
      end

      def artist_commentary_desc
        api_metadata[:description]
      end

      def normalizable_for_artist_finder?
        url !~ %r!^https?://www.deviantart.com/!
      end

      def normalized_for_artist_finder?
        url =~ %r!^https?://www.deviantart.com/! 
      end

      def normalize_for_artist_finder!
        profile_url
      end

      protected

      def normalized_url
        @normalized_url ||= self.class.normalize(url)
      end

      def page
        options = Danbooru.config.httparty_options.deep_merge(format: :plain, headers: { "Accept-Encoding" => "gzip" })
        resp = HTTParty.get(normalized_url, **options)
        body = Zlib.gunzip(resp.body)
        Nokogiri::HTML(body)
      end

      # Scrape UUID from <meta property="da:appurl" content="DeviantArt://deviation/12F08C5D-A3A4-338C-2F1A-7E4E268C0E8B">
      # For private works the UUID will be nil.
      def uuid
        meta = page.search('meta[property="da:appurl"]').first
        return nil if meta.nil?

        appurl = meta["content"]
        uuid = appurl[%r!\ADeviantArt://deviation/(.*)\z!, 1]
        uuid
      end

      def api_client
        api_client = DeviantArtApiClient.new(Danbooru.config.deviantart_client_id, Danbooru.config.deviantart_client_secret, Danbooru.config.httparty_options)
        api_client.access_token = Cache.get("da-access-token", 55.minutes) { api_client.access_token.to_hash }
        api_client
      end

      def api_deviation
        return {} if uuid.nil?
        api_client.deviation(uuid)
      end

      def api_metadata
        return {} if uuid.nil?
        api_client.metadata(uuid)[:metadata].first
      end

      def api_download
        return {} if uuid.nil?
        api_client.download(uuid)
      end

      memoize :page, :uuid, :api_client, :api_deviation, :api_metadata, :api_download
    end
  end
end
