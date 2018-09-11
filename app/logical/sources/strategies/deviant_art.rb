# Asset URLs:
#
# * http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
# * http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
# * http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
#
# * http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
# * http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
# * http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
#
# * http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg
# * http://img04.deviantart.net/720b/i/2003/37/9/6/princess_peach.jpg
#
# * http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg
# * http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
# * http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
#
# * http://fc09.deviantart.net/fs22/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
# * http://pre06.deviantart.net/8497/th/pre/f/2009/173/c/c/cc9686111dcffffffb5fcfaf0cf069fb.jpg
#
# Page URLs:
#
# * https://www.deviantart.com/noizave/art/test-post-please-ignore-685436408
# * https://noizave.deviantart.com/art/test-post-please-ignore-685436408
# * https://www.deviantart.com/deviation/685436408
# * https://fav.me/dbc3a48
#
# Profile URLs:
#
# * https://noizave.deviantart.com
# * https://www.deviantart.com/noizave
# * https://deviantart.com/noizave

module Sources
  module Strategies
    class DeviantArt < Base
      ASSET_SUBDOMAINS = %r{(?:fc|th|pre|img|orig|origin-orig)\d*}i
      RESERVED_SUBDOMAINS = %r{\Ahttps?://(?:#{ASSET_SUBDOMAINS}|www)\.}i

      TITLE = %r{(?<title>[a-z0-9_-]+?)}i
      ARTIST = %r{(?<artist>[a-z0-9_-]+?)}i
      DEVIATION_ID = %r{(?<deviation_id>[0-9]+)}i

      ASSET = %r{\Ahttps?://#{ASSET_SUBDOMAINS}\.deviantart\.net/.+/#{TITLE}(?:_by_#{ARTIST}(?:-d(?<base36_deviation_id>\w+))?)?\.}i

      PATH_ART = %r{\Ahttps?://www\.deviantart\.com/#{ARTIST}/art/#{TITLE}-#{DEVIATION_ID}\z}i
      SUBDOMAIN_ART = %r{\Ahttps?://#{ARTIST}\.deviantart\.com/art/#{TITLE}-#{DEVIATION_ID}\z}i

      PATH_PROFILE = %r{\Ahttps?://(www\.)?deviantart\.com/#{ARTIST}/?\z}i
      SUBDOMAIN_PROFILE = %r{\Ahttps?://#{ARTIST}\.deviantart\.com/?\z}i

      def self.match?(*urls)
        urls.compact.any? { |x| x.match?(/^https?:\/\/(?:.+?\.)?deviantart\.(?:com|net)/) }
      end

      def site_name
        "Deviant Art"
      end

      def canonical_url
        if self.class.deviation_id_from_url(image_url).present? || page_url.blank?
          image_url
        else
          page_url
        end
      end

      def image_urls
        # work is private, deleted, or the url didn't contain a deviation id; use image url as given by user.
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
        if api_deviation.present?
          api_deviation[:url]
        elsif api_url.present?
          api_url
        else
          ""
        end
      end

      def profile_url
        return "" if artist_name.blank?
        "https://www.deviantart.com/#{artist_name.downcase}"
      end

      # Prefer the name from the url because the api metadata won't be present when
      # the input url doesn't contain a deviation id, or the deviation is private or deleted.
      def artist_name
        if artist_name_from_url.present?
          artist_name_from_url
        elsif api_metadata.present?
          api_metadata.dig(:author, :username)
        else
          ""
        end
      end

      def artist_commentary_title
        api_metadata[:title]
      end

      def artist_commentary_desc
        api_metadata[:description]
      end

      def normalized_for_artist_finder?
        url == normalize_for_artist_finder
      end

      def normalizable_for_artist_finder?
        normalize_for_artist_finder.present?
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

      def self.deviation_id_from_url(url)
        if url =~ ASSET
          $~[:base36_deviation_id].try(:to_i, 36)
        elsif url =~ PATH_ART || (url !~ RESERVED_SUBDOMAINS && url =~ SUBDOMAIN_ART)
          $~[:deviation_id].to_i
        else
          nil
        end
      end

      def self.artist_name_from_url(url)
        if url =~ ASSET || url =~ PATH_ART || url =~ PATH_PROFILE
          $~[:artist].try(:dasherize)
        elsif url !~ RESERVED_SUBDOMAINS && (url =~ SUBDOMAIN_ART || url =~ SUBDOMAIN_PROFILE)
          $~[:artist]
        else
          nil
        end
      end

      def deviation_id
        self.class.deviation_id_from_url(url) || self.class.deviation_id_from_url(referer_url)
      end

      def artist_name_from_url
        self.class.artist_name_from_url(url) || self.class.artist_name_from_url(referer_url)
      end

      def api_url
        return nil if deviation_id.blank?
        "https://www.deviantart.com/deviation/#{deviation_id}"
      end

      def page
        return nil if api_url.blank?

        options = Danbooru.config.httparty_options.deep_merge(
          format: :plain, 
          headers: { "Accept-Encoding" => "gzip" }
        )
        resp = HTTParty.get(api_url, **options)

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
