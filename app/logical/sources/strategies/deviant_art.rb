module Sources
  module Strategies
    class DeviantArt < Base
      ASSET_SUBDOMAINS = %r{(?:fc|th|pre|img|orig|origin-orig)\d*}i
      ATTRIBUTED_ASSET = %r{\Ahttps?://#{ASSET_SUBDOMAINS}\.deviantart\.net/.+/[a-z0-9_]*_by_[a-z0-9_]+-d([a-z0-9]+)\.}i
      ASSET = %r{\Ahttps?://#{ASSET_SUBDOMAINS}\.deviantart\.net/.+/[a-f0-9]+-d([a-z0-9]+)\.}i
      PATH_ART = %r{\Ahttps?://www\.deviantart\.com/([^/]+)/art/}
      RESERVED_SUBDOMAINS = %r{\Ahttps?://(?:#{ASSET_SUBDOMAINS}|www)\.}
      SUBDOMAIN_ART = %r{\Ahttps?://(.+?)\.deviantart\.com(.*)}
      PROFILE = %r{\Ahttps?://www\.deviantart\.com/([^/]+)/?\z}

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(/^https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/) }
      end

      def site_name
        "Deviant Art"
      end

      def image_urls
        # work is private or deleted, use image url as given by user.
        if api_deviation.blank?
          [url]
        # work is downloadable
        elsif api_deviation[:is_downloadable] && api_deviation[:download_filesize] != api_deviation.dig(:content, :filesize)
          src = api_download[:src]
          src.gsub!(%r!\Ahttps?://s3\.amazonaws\.com/!i, "https://")
          src.gsub!(/\?.*\z/, "") # strip s3 query params
          src.gsub!(%r!\Ahttps://origin-orig\.deviantart\.net!, "http://origin-orig.deviantart.net") # https://origin-orig.devianart.net doesn't work
          [src]
        # work isn't downloadable, or download size is same as regular size.
        elsif api_deviation.present?
          src = api_deviation.dig(:content, :src)
          src = src.gsub(%r!\Ahttps?://orig\d+\.deviantart\.net!i, "http://origin-orig.deviantart.net")
          [src]
        else
          raise "Couldn't find image url" # this should never happen
        end
      end

      def page_url
        [url, referer_url].each do |x|
          if x =~ ATTRIBUTED_ASSET
            return "http://fav.me/d#{$1}"
          end

          if x =~ ASSET
            return "http://fav.me/d#{$1}"
          end

          if x =~ PATH_ART
            return x
          end

          if x !~ RESERVED_SUBDOMAINS && x =~ SUBDOMAIN_ART
            return "http://www.deviantart.com/#{$1}#{$2}"
          end
        end

        return super
      end

      def profile_url
        if url =~ PROFILE
          return url
        end

        if artist_name.blank?
          return nil
        end

        return "https://www.deviantart.com/#{artist_name}"
      end

      def artist_name
        api_metadata.dig(:author, :username).try(&:downcase)
      end

      def artist_commentary_title
        api_metadata[:title]
      end

      def artist_commentary_desc
        api_metadata[:description]
      end

      def normalized_for_artist_finder?
        url =~ PROFILE
      end

      def normalizable_for_artist_finder?
        url =~ PATH_ART || url =~ SUBDOMAIN_ART
      end

      def normalize_for_artist_finder
        profile_url
      end

      def tags
        if api_metadata.blank?
          return []
        end

        api_metadata[:tags].map do |tag|
          [tag[:tag_name], "https://www.deviantart.com/tag/#{tag[:tag_name]}"]
        end
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

    public

      def page
        options = Danbooru.config.httparty_options.deep_merge(
          format: :plain, 
          headers: { "Accept-Encoding" => "gzip" }
        )
        resp = HTTParty.get(page_url, **options)

        if resp.success?
          body = Zlib.gunzip(resp.body)
          Nokogiri::HTML(body)
        # the work was deleted
        elsif resp.code == 404
          nil
        else
          raise HTTParty::ResponseError.new(resp)
        end
      end
      memoize :page

      # Scrape UUID from <meta property="da:appurl" content="DeviantArt://deviation/12F08C5D-A3A4-338C-2F1A-7E4E268C0E8B">
      # For hidden or deleted works the UUID will be nil.
      def uuid
        return nil if page.nil?
        meta = page.search('meta[property="da:appurl"]').first
        return nil if meta.nil?

        appurl = meta["content"]
        uuid = appurl[%r!\ADeviantArt://deviation/(.*)\z!, 1]
        uuid
      end
      memoize :uuid

      def api_client
        api_client = DeviantArtApiClient.new(
          Danbooru.config.deviantart_client_id, 
          Danbooru.config.deviantart_client_secret, 
          Danbooru.config.httparty_options
        )
        api_client.access_token = Cache.get("da-access-token", 55.minutes) do
          api_client.access_token.to_hash
        end
        api_client
      end
      memoize :api_client

      def api_deviation
        return {} if uuid.nil?
        api_client.deviation(uuid)
      end
      memoize :api_deviation

      def api_metadata
        return {} if uuid.nil?
        api_client.metadata(uuid)[:metadata].first
      end
      memoize :api_metadata

      def api_download
        return {} if uuid.nil?
        api_client.download(uuid)
      end
      memoize :api_download

    end
  end
end
