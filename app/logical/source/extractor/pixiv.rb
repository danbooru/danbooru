# frozen_string_literal: true

# @see Source::URL::Pixiv
module Source
  class Extractor
    class Pixiv < Source::Extractor
      def self.enabled?
        SiteCredential.for_site("Pixiv").present?
      end

      def image_urls
        # For ugoira we have to fetch the frame metadata from the API, which may be incorrect for revisions.
        # Therefore, check that the date in the URL matches the date of the latest revision URL from the API.
        #
        # https://i.pximg.net/img-zip-ugoira/img/2024/10/17/12/31/43/123406986_ugoira1920x1080.zip
        # https://i.pximg.net/img-zip-ugoira/img/2024/10/22/02/32/43/123406986_ugoira1920x1080.zip
        if parsed_url.ugoira_zip_url? && parsed_url.date != ugoira_zip_url.date
          [] # Return nothing because the ugoira has been revised, so we can't be sure we have the correct frame delays.
        # If it's a full image URL, then use it as-is instead of looking it up in the API, because it could be the
        # original version of an image that has since been revised.
        elsif parsed_url.full_image_url.present?
          [parsed_url.full_image_url]
        # If it's a sample image URL, then try to get the full image URL without the API in case the post has been deleted.
        elsif parsed_url.candidate_full_image_urls.present?
          [parsed_url.candidate_full_image_urls.find { |url| http_exists?(url) } || url.to_s]
        # If it's a very old sample image URL with a page number but no date, then try to find the full image URL in the API if possible.
        elsif parsed_url.image_url? && parsed_url.page && original_urls.present?
          [original_urls[parsed_url.page]]
        # Otherwise if it's an unknown image URL, then just use the image as is.
        elsif parsed_url.image_url?
          [parsed_url.to_s]
        else
          original_urls
        end
      end

      def original_urls
        if ugoira_zip_url.present?
          [ugoira_zip_url.to_s]
        elsif api_pages.present?
          api_pages.pluck("urls").pluck("original").to_a
        elsif api_novel.present?
          cover_url = Source::URL.parse(api_novel[:coverUrl]).candidate_full_image_urls.find { |url| http_exists?(url) } || api_novel[:coverUrl]
          embedded_urls = api_novel[:textEmbeddedImages]&.values&.pluck("urls")&.pluck("original")

          [cover_url, *embedded_urls]
        elsif api_novel_series.present?
          [api_novel_series.dig(:cover, :urls, :original)].compact
        else
          []
        end
      end

      def profile_url
        if api_response[:userId].present?
          "https://www.pixiv.net/users/#{api_response[:userId]}"
        else
          parsed_url.profile_url || parsed_referer&.profile_url
        end
      end

      def stacc_url
        "https://www.pixiv.net/stacc/#{username}" if username.present?
      end

      def profile_urls
        [profile_url, stacc_url].compact
      end

      def display_name
        api_response[:userName]
      end

      def username
        parsed_url.username || parsed_referer&.username || api_illust[:userAccount]
      end

      def other_names
        [display_name, (username unless username&.starts_with?("user_"))].compact_blank.uniq(&:downcase)
      end

      def artist_commentary_title
        api_response[:title]&.normalize_whitespace
      end

      def artist_commentary_desc
        api_response[:description] || api_novel_series[:caption]
      end

      def dtext_artist_commentary_desc
        if api_novel_series.present?
          DText.from_plaintext(artist_commentary_desc)
        else
          text = artist_commentary_desc.to_s

          text = text.gsub(%r{<a href="https?://www\.pixiv\.net/(?:[a-z]+/)?artworks/([0-9]+)">illust/[0-9]+</a>}i) do |_match|
            pixiv_id = $1
            %{pixiv ##{pixiv_id} "»":[#{Routes.posts_path(tags: "pixiv:#{pixiv_id}")}]}
          end

          text = text.gsub(%r{<a href="https?://www\.pixiv\.net/(?:[a-z]+/)?users/([0-9]+)">user/[0-9]+</a>}i) do |_match|
            member_id = $1
            profile_url = "https://www.pixiv.net/users/#{member_id}"

            artist_search_url = Routes.artists_path(search: { url_matches: profile_url })

            %{"user/#{member_id}":[#{profile_url}] "»":[#{artist_search_url}]}
          end

          DText.from_html(text, base_url: "https://www.pixiv.net", allowed_shortlinks: ["pixiv"]) do |element|
            # <a href="/jump.php?https%3A%2F%2Fshop.akbh.jp%2Fcollections%2Fvendors%3Fq%3D%25E7%258E%2589%25E4%25B9%2583%25E9%259C%25B2%26sort_by%3Dcreated-descending" target="_blank" rel="noopener">https://shop.akbh.jp/collections/vendors?q=%E7%8E%89%E4%B9%83%E9%9C%B2&amp;sort_by=created-descending</a>
            if element.name == "a" && element["href"]&.starts_with?("/jump.php")
              url = element["href"].delete_prefix("/jump.php?")
              element["href"] = Danbooru::URL.unescape(url)
            end
          end
        end
      end

      def tags
        if api_illust.present?
          api_tags = api_illust.dig(:tags, :tags).to_a.pluck(:tag)
          tag_type = "artworks"
        elsif api_novel.present?
          api_tags = api_novel.dig(:tags, :tags).to_a.pluck(:tag)
          tag_type = "novels"
        elsif api_novel_series.present?
          api_tags = api_novel_series[:tags].to_a
          tag_type = "novels"
        else
          api_tags = []
        end

        tags = api_tags.map do |tag|
          [tag, "https://www.pixiv.net/tags/#{Danbooru::URL.escape(tag)}/#{tag_type}"]
        end

        if api_illust["aiType"] == 2
          # XXX There's no way to search for posts with the AI flag on Pixiv. The "AI" tag is the closest equivalent.
          tags += [["AI", "https://www.pixiv.net/tags/AI/#{tag_type}"]]
        end

        if api_illust["request"].present?
          # XXX There's no way to search for posts commissioned via Pixiv Requests on Pixiv. The "依頼絵" ("commission") tag is the closest equivalent.
          tags += [["pixiv_commission", "https://www.pixiv.net/tags/依頼絵/#{tag_type}"]]
        end

        if api_response["isOriginal"].present?
          tags += [["original", "https://www.pixiv.net/tags/オリジナル/#{tag_type}"]]
        end

        tags
      end

      def normalize_tag(tag)
        tag.gsub(/\d+users入り\z/i, "")
      end

      def download_file!(url)
        url = Source::URL.parse(url)

        if url.ugoira_zip_url? && url.params.key?(:original)
          ugoira_file
        else
          super(url.to_s)
        end
      end

      # @return [Source::URL, nil] The URL to the current ugoira zip file, or nil if this is not a ugoira.
      memoize def ugoira_zip_url
        frame_url = api_pages.pluck("urls")&.pick("original")
        zip_url = Source::URL.parse(frame_url)&.ugoira_zip_url

        Source::URL.parse(zip_url)
      end

      # @return [Array<String>] The list of URLs to the individual frames in the original ugoira.
      memoize def ugoira_frame_urls
        base_frame_url = api_pages.pluck("urls")&.pick("original")&.then { |url| Source::URL.parse(url) }

        ugoira_frame_delays.size.times.map do |n|
          base_frame_url.ugoira_frame_url(n)
        end
      end

      # @return [Array<MediaFile>] The list of individual frames in the original ugoira.
      memoize def ugoira_frames
        ugoira_frame_urls.parallel_map do |url|
          # XXX dup the downloader to avoid sharing it across threads because the underlying HTTP.rb library isn't thread-safe.
          _, file = http_downloader.dup.download_media(url)
          file
        end
      end

      # @return [MediaFile, nil] The original ugoira built from the individual frames.
      memoize def ugoira_file
        return unless ugoira_frames.present? && ugoira_frame_delays.present?

        # Use the date from the URL for timestamps in the zipfile because it includes the seconds and the uploadDate
        # from the API doesn't, and because it's what gallery-dl does.
        mtime = Source::URL.parse(ugoira_frame_urls.first).parsed_date

        MediaFile::Ugoira.create(ugoira_frames, frame_delays: ugoira_frame_delays, mtime: mtime, data: {
          illustId: api_response[:illustId].to_i,
          userId: api_response[:userId].to_i,
          createDate: api_response[:createDate], # when the ugoira was first uploaded
          uploadDate: api_response[:uploadDate], # when the ugoira was last revised (same as the creation date if not revised)
        })
      end

      def translate_tag(tag)
        translated_tags = super(tag)

        if translated_tags.empty? && tag.include?("/")
          translated_tags = tag.split("/").flat_map { |translated_tag| super(translated_tag) }
        end

        translated_tags
      end

      def related_posts_search_query
        illust_id.present? ? "pixiv:#{illust_id}" : "source:#{url}"
      end

      def is_ugoira?
        parsed_url.is_ugoira? || original_urls.any? { |url| Source::URL.parse(url).is_ugoira? }
      end

      memoize def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      memoize def novel_id
        parsed_url.novel_id || parsed_referer&.novel_id
      end

      memoize def novel_series_id
        parsed_url.novel_series_id || parsed_referer&.novel_series_id
      end

      def http
        super.cookies(PHPSESSID: credentials[:phpsessid])
      end

      memoize def api_illust
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/87598468" | jq
        parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}")&.dig("body") || {}
      end

      memoize def api_pages
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/87598468/pages" | jq
        parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/pages")&.dig("body") || {}
      end

      memoize def api_ugoira
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/74932152/ugoira_meta" | jq
        parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/ugoira_meta")&.dig("body") || {}
      end

      memoize def api_novel
        return {} unless novel_id.present?

        # curl "https://www.pixiv.net/ajax/novel/74932152" | jq
        # curl "https://www.pixiv.net/ajax/user/66091066/novels/tags" | jq
        parsed_get("https://www.pixiv.net/ajax/novel/#{novel_id}")&.dig("body") || {}
      end

      memoize def api_novel_series
        return {} unless novel_series_id.present?

        # curl "https://www.pixiv.net/ajax/novel/series/9593812" | jq
        # curl "https://www.pixiv.net/ajax/novel/series_content/9593812" | jq
        parsed_get("https://www.pixiv.net/ajax/novel/series/#{novel_series_id}")&.dig("body") || {}
      end

      memoize def api_response
        api_illust.presence || api_novel.presence || api_novel_series.presence || {}
      end

      def ugoira_frame_delays
        api_ugoira[:frames].to_a.pluck("delay")
      end
    end
  end
end
