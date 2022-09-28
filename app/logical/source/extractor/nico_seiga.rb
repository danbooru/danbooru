# frozen_string_literal: true

# @see Source::URL::NicoSeiga
module Source
  class Extractor
    class NicoSeiga < Source::Extractor
      def self.enabled?
        Danbooru.config.nico_seiga_user_session.present?
      end

      def match?
        Source::URL::NicoSeiga === parsed_url
      end

      def image_urls
        if image_id.present?
          [image_url_for("https://seiga.nicovideo.jp/image/source/#{image_id}")]
        elsif illust_id.present?
          [image_url_for("https://seiga.nicovideo.jp/image/source/#{illust_id}")]
        elsif manga_id.present? && api_client.image_ids.present?
          api_client.image_ids.map { |id| image_url_for("https://seiga.nicovideo.jp/image/source/#{id}") }
        else
          [image_url_for(url)]
        end
      end

      def image_url_for(url)
        return url if api_client.blank?

        resp = api_client.head(url)
        if resp.uri.to_s =~ %r{https?://.+/(\w+/\d+/\d+)\z}i
          "https://lohas.nicoseiga.jp/priv/#{$1}"
        else
          url
        end
      end

      def page_url
        parsed_referer&.page_url || parsed_url.page_url
      end

      def profile_url
        "https://seiga.nicovideo.jp/user/illust/#{api_client.user_id}" if api_client&.user_id.present?
      end

      def artist_name
        return if api_client.blank?
        api_client.user_name
      end

      def artist_commentary_title
        return if api_client.blank?
        api_client.title
      end

      def artist_commentary_desc
        return if api_client.blank?
        api_client.description
      end

      def dtext_artist_commentary_desc
        DText.from_html(artist_commentary_desc) do |element|
          if element.name == "font" && element["color"] == "white"
            element.content = "[spoiler]#{element.content}[/spoiler]"
          end
        end.gsub(/[^\w]im(\d+)/, ' seiga #\1 ').chomp
      end

      def tag_name
        return if api_client&.user_id.blank?
        "nicoseiga#{api_client.user_id}"
      end

      def tags
        return [] if api_client.blank?

        base_url = "https://seiga.nicovideo.jp/"
        base_url += "manga/" if manga_id.present?
        base_url += "tag/"

        api_client.tags.map do |name|
          [name, base_url + CGI.escape(name)]
        end
      end

      def image_id
        parsed_url.image_id || parsed_referer&.image_id
      end

      def illust_id
        parsed_url.illust_id || parsed_referer&.illust_id
      end

      def manga_id
        parsed_url.manga_id || parsed_referer&.manga_id
      end

      def http
        if parsed_url.oekaki_id.present?
          super.with_legacy_ssl
        else
          super
        end
      end

      def api_client
        if illust_id.present?
          NicoSeigaApiClient.new(work_id: illust_id, type: "illust", http: http)
        elsif manga_id.present?
          NicoSeigaApiClient.new(work_id: manga_id, type: "manga", http: http)
        elsif image_id.present?
          # We default to illust to attempt getting the api anyway
          NicoSeigaApiClient.new(work_id: image_id, type: "illust", http: http)
        end
      end
      memoize :api_client
    end
  end
end
