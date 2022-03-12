# frozen_string_literal: true

module Sources
  module Strategies
    class DeviantArt < Base
      def self.enabled?
        Danbooru.config.deviantart_client_id.present? && Danbooru.config.deviantart_client_secret.present?
      end

      def match?
        Source::URL::DeviantArt === parsed_url
      end

      def image_urls
        [image_url]
      end

      def image_url
        # work is private, deleted, or the url didn't contain a deviation id; use image url as given by user.
        if api_deviation.blank?
          url
        elsif api_deviation[:is_downloadable]
          api_download[:src]
        elsif api_deviation[:flash].present?
          api_deviation.dig(:flash, :src)
        elsif api_deviation[:videos].present?
          api_deviation[:videos].max_by { |x| x[:filesize] }[:src]
        else
          src = api_deviation.dig(:content, :src)
          if deviation_id && deviation_id.to_i <= 790_677_560 && src =~ %r{\Ahttps://images-wixmp-} && src !~ /\.gif\?/
            src = src.sub(%r{(/f/[a-f0-9-]+/[a-f0-9-]+)}, '/intermediary\1')
            src = src.sub(%r{/v1/(fit|fill)/.*\z}i, "")
          end
          src = src.sub(%r{\Ahttps?://orig\d+\.deviantart\.net}i, "http://origin-orig.deviantart.net")
          src = src.gsub(/q_\d+,strp/, "q_100")
          src
        end
      end

      def page_url
        if api_deviation.present?
          api_deviation[:url]
        elsif deviation_id.present?
          page_url_from_image_url
        else
          nil
        end
      end

      def page_url_from_image_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def normalize_for_source
        page_url_from_image_url
      end

      def profile_url
        return nil if artist_name.blank?
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
          nil
        end
      end

      def artist_commentary_title
        api_metadata[:title]
      end

      def artist_commentary_desc
        api_metadata[:description]
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
              deviation_id = element["href"][/-(\d+)\z/, 1].to_i
              element.content = "deviantart ##{deviation_id}"
            else
              element.content = ""
            end
          end

          if element.name == "a" && element["href"].present?
            element["href"] = element["href"].gsub(%r{\Ahttps?://www\.deviantart\.com/users/outgoing\?}i, "")

            # href may be missing the `http://` bit (ex: `inprnt.com`, `//inprnt.com`). Add it if missing.
            uri = Addressable::URI.heuristic_parse(element["href"]) rescue nil
            if uri.present? && uri.path.present?
              uri.scheme ||= "http"
              element["href"] = uri.to_s
            end
          end
        end.gsub(/\A[[:space:]]+|[[:space:]]+\z/, "")
      end

      def deviation_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def artist_name_from_url
        parsed_url.username || parsed_referer&.username
      end

      def page
        return nil if page_url_from_image_url.blank?

        resp = http.cache(1.minute).get(page_url_from_image_url, follow: {max_hops: 1})

        if resp.status.success?
          resp.parse
        # the work was deleted
        elsif resp.code == 404
          nil
        else
          raise "failed to fetch page (got code #{resp.code})"
        end
      end
      memoize :page

      # Scrape UUID from <meta property="da:appurl" content="DeviantArt://deviation/12F08C5D-A3A4-338C-2F1A-7E4E268C0E8B">
      # For hidden or deleted works the UUID will be nil.
      def uuid
        return nil if page.nil?
        meta = page.at_css('meta[property="da:appurl"]')
        return nil if meta.nil?

        appurl = meta["content"]
        uuid = appurl[%r{\ADeviantArt://deviation/(.*)\z}, 1]
        uuid
      end
      memoize :uuid

      def api_client
        api_client = DeviantArtApiClient.new(
          Danbooru.config.deviantart_client_id,
          Danbooru.config.deviantart_client_secret
        )
        api_client.access_token = Cache.get("da-access-token", 11.weeks) do
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
        return {} unless uuid.present? && api_deviation[:is_downloadable]
        api_client.download(uuid)
      end
      memoize :api_download

      def api_response
        {
          deviation: api_deviation,
          metadata: api_metadata,
          download: api_download
        }
      end
    end
  end
end
