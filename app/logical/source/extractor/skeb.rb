# frozen_string_literal: true

# @see Source::URL::Skeb
module Source
  class Extractor
    class Skeb < Extractor
      def image_urls
        if parsed_url.image_url?
          [url]
        elsif unwatermarked_url.present?
          # If the unwatermarked URL is present, then find and replace the watermarked URL
          # with the unwatermarked version (unless the watermarked version is a video or
          # gif, in which case the unwatermarked URL is not used because it's a still image).
          #
          # https://skeb.jp/@goma_feet/works/1: https://skeb.imgix.net/uploads/origins/78ca23dc-a053-4ebe-894f-d5a06e228af8?bg=%23fff&auto=format&w=800&s=3de55b04236059113659f99fd6900d7d
          # https://skeb.jp/@2gi0gi_/works/13: https://skeb.imgix.net/requests/191942_0?bg=%23fff&fm=jpg&q=45&w=696&s=5783ee951cc55d183713395926389453
          # https://skeb.jp/@tontaro_/works/316: https://skeb.imgix.net/uploads/origins/5097b1e1-18ce-418e-82f0-e7e2cdab1cea?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&fm=mp4&w=800&s=fcff06871e114b3dbf505c04f27b5ed1
          sample_urls.map do |sample_url|
            if sample_url.path == unwatermarked_url.path && sample_url.watermarked? && !sample_url.animated?
              unwatermarked_url
            else
              sample_url
            end
          end.map(&:to_s)
        else
          sample_urls.map(&:to_s)
        end
      end

      def sample_urls
        api_response["previews"].to_a.pluck("url").compact.map { |url| Source::URL.parse(url) }
      end

      # Some posts have an unwatermarked version of the image. Usually it's lower
      # resolution and lower JPEG quality than the watermarked image. Multi-image posts
      # will have only one unwatermarked URL.
      def unwatermarked_url
        return nil if api_response["article_image_url"].nil?
        Source::URL.parse(api_response["article_image_url"])
      end

      def page_url
        if api_response[:path].present?
          # https://skeb.jp/@kotora_hu/works/1
          "https://skeb.jp#{api_response[:path]}"
        else
          parsed_url.page_url || parsed_referer&.page_url
        end
      end

      def api_url
        parsed_url.api_url || parsed_referer&.api_url
      end

      memoize def api_response
        return {} unless api_url.present?

        response = http.cache(1.minute).get(api_url)

        if response.status == 429
          self.cached_request_key = response.cookies.cookies.find do
            |cookie| cookie.name == "request_key"
          end&.value
          response = http.cache(1.minute).get(api_url)
        end

        return {} if response.mime_type == "text/html"
        response.parse
      end

      def http
        super.headers(Authorization: "Bearer null").cookies(request_key: cached_request_key)
      end

      memoize def cached_request_key
        Cache.get("skeb-request-key", 24.hours, skip_nil: true)
      end

      def cached_request_key=(value)
        Cache.put("skeb-request-key", value)
        cached_request_key(true)
      end

      def profile_url
        "https://skeb.jp/@#{username}" if username.present?
      end

      def display_name
        api_response&.dig("creator", "name")
      end

      def username
        Source::URL.parse(page_url)&.username
      end

      def artist_commentary_desc
        api_response&.dig("source_body") || api_response&.dig("body")
        # skeb "titles" are not needed: it's just the first few characters of the description
      end

      def client_response
        api_response&.dig("source_thanks") || api_response&.dig("thanks")
      end

      def dtext_artist_commentary_desc
        if client_response.present? && artist_commentary_desc.present?
          <<~EOS.chomp
            h6. Original Request

            #{DText.from_plaintext(artist_commentary_desc)}

            h6. Client Response

            #{DText.from_plaintext(client_response)}
          EOS
        else
          DText.from_plaintext(artist_commentary_desc)
        end
      end
    end
  end
end
