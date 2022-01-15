# frozen_string_literal: true

# Image URLS
## Non-watermarked:
# * https://skeb.imgix.net/requests/199886_0?bg=%23fff&auto=format&w=800&s=5a6a908ab964fcdfc4713fad179fe715
## Watermarked:
# * https://skeb.imgix.net/requests/73290_0?bg=%23fff&auto=format&txtfont=bold&txtshad=70&txtclr=BFFFFFFF&txtalign=middle%2Ccenter&txtsize=150&txt=SAMPLE&w=800&s=4843435cff85d623b1f657209d131526
# * https://skeb.imgix.net/uploads/origins/04d62c2f-e396-46f9-903a-3ca8bd69fc7c?bg=%23fff&auto=format&w=800&s=966c5d0389c3b94dc36ac970f812bef4 (new format)
## Full Size (found in commissioner_upload):
# * https://skeb.imgix.net/requests/53269_1?bg=%23fff&fm=png&dl=53269.png&w=1.0&h=1.0&s=44588ea9c41881049e392adb1df21cce
#
# The signature is required and tied to the parameters. Doesn't seem like it's possible to reverse engineer it to remove the watermark, unfortunately.
#
# Page URLS
# * https://skeb.jp/@OrvMZ/works/3 (non-watermarked)
# * https://skeb.jp/@OrvMZ/works/1 (separated request and client's message after delivery. We can't get the latter)
# * https://skeb.jp/@asanagi/works/16 (age-restricted, watermarked)
# * https://skeb.jp/@asanagi/works/6 (private, returns 404)
# * https://skeb.jp/@nasuno42/works/30 (multi-image post)
#
# Profile URLS
# Since skeb forces login through twitter, usernames are the same as twitter
# * https://skeb.jp/@asanagi

module Sources
  module Strategies
    class Skeb < Base
      PROFILE_URL = %r{https?://(?:www\.)?skeb\.jp/@(?<artist_name>\w+)}i
      PAGE_URL    = %r{#{PROFILE_URL}/works/(?<illust_id>\d+)}i
      IMAGE_URL   = %r{https?://(?:(?:www\.)?skeb\.imgix\.net|skeb-production.s3.ap-northeast-1.amazonaws.com/)/.+}i
      UUID_REGEX  = %r{/(?<uuid>(?:(?:\w+-)+\w+|(?:\d+_\d+))).*(?:fm=(?<type>\w+))?.*}

      def domains
        ["skeb.jp"]
      end

      def image_domains
        ["skeb.imgix.net", "skeb-production.s3.ap-northeast-1.amazonaws.com"]
      end

      def match?
        return false if parsed_url.nil?
        parsed_url.domain.in?(domains) || parsed_url.host.in?(image_domains)
      end

      def site_name
        "Skeb"
      end

      def image_urls
        if url =~ IMAGE_URL
          [url]
        elsif api_response.present?
          previews = api_response["previews"].to_a.map { |preview| preview&.dig("url") }.compact.uniq

          unwatermarked = api_response["article_image_url"]
          return previews unless unwatermarked.present?
          previews.map do |p|
            next p unless p[UUID_REGEX, :uuid].present? && p[UUID_REGEX, :uuid] == unwatermarked[UUID_REGEX, :uuid]
            next p if p[/fm=(\w+)/, 1].in?(["gif", "mp4"])
            next p unless p.include?("&txt=")

            unwatermarked
          end
        else
          []
        end
      end

      def page_url
        return unless artist_name.present? && illust_id.present?
        "https://skeb.jp/@#{artist_name}/works/#{illust_id}"
      end

      def normalize_for_source
        page_url
      end

      def api_response
        return {} unless artist_name.present? && illust_id.present?
        headers = {
          Referer: profile_url,
          Authorization: "Bearer null",
        }
        api_url = "https://skeb.jp/api/users/#{artist_name}/works/#{illust_id}"
        response = http.cache(1.minute).headers(headers).get(api_url)
        return {} unless response.status == 200
        # The status check is required for private commissions, which return 404

        response.parse
      end

      def profile_url
        return nil if artist_name.blank?
        "https://skeb.jp/@#{artist_name}"
      end

      def artist_name
        urls.map { |u| u[PROFILE_URL, :artist_name] }.compact.first
      end

      def display_name
        api_response&.dig("creator", "name")
      end

      def illust_id
        urls.map { |u| u[PAGE_URL, :illust_id] }.compact.first
      end

      def other_names
        [display_name].compact.uniq
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
          "h6. Original Request:\n\n#{artist_commentary_desc}\n\nh6. Client Response:\n\n#{client_response}"
        else
          artist_commentary_desc
        end
      end
    end
  end
end
