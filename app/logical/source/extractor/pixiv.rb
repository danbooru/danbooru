# frozen_string_literal: true

# @see Source::URL::Pixiv
module Source
  class Extractor
    class Pixiv < Source::Extractor
      def self.enabled?
        Danbooru.config.pixiv_phpsessid.present?
      end

      def image_urls
        if is_ugoira?
          [api_ugoira[:originalSrc]]
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
        if api_pages.present?
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

      def page_url
        parsed_url.page_url || parsed_referer&.page_url
      end

      def profile_url
        if api_response[:userId].present?
          "https://www.pixiv.net/users/#{api_response[:userId]}"
        else
          parsed_url.profile_url || parsed_referer&.profile_url
        end
      end

      def stacc_url
        return nil if moniker.blank?
        "https://www.pixiv.net/stacc/#{moniker}"
      end

      def profile_urls
        [profile_url, stacc_url].compact
      end

      def artist_name
        api_response[:userName]
      end

      def other_names
        other_names = [artist_name]
        other_names << moniker unless moniker&.starts_with?("user_")
        other_names.compact.uniq
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

      def tag_name
        moniker
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
        media_file = super(url)
        media_file.frame_delays = ugoira_frame_delays if is_ugoira?
        media_file
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
        original_urls.any? { |url| Source::URL.parse(url).is_ugoira? }
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
        super.cookies(PHPSESSID: Danbooru.config.pixiv_phpsessid)
      end

      memoize def api_illust
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/87598468" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}")&.dig("body") || {}
      end

      memoize def api_pages
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/87598468/pages" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/pages")&.dig("body") || {}
      end

      memoize def api_ugoira
        return {} unless illust_id.present?

        # curl "https://www.pixiv.net/ajax/illust/74932152/ugoira_meta" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/ugoira_meta")&.dig("body") || {}
      end

      memoize def api_novel
        return {} unless novel_id.present?

        # curl "https://www.pixiv.net/ajax/novel/74932152" | jq
        # curl "https://www.pixiv.net/ajax/user/66091066/novels/tags" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/novel/#{novel_id}")&.dig("body") || {}
      end

      memoize def api_novel_series
        return {} unless novel_series_id.present?

        # curl "https://www.pixiv.net/ajax/novel/series/9593812" | jq
        # curl "https://www.pixiv.net/ajax/novel/series_content/9593812" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/novel/series/#{novel_series_id}")&.dig("body") || {}
      end

      memoize def api_response
        api_illust.presence || api_novel.presence || api_novel_series.presence || {}
      end

      def moniker
        parsed_url.username || api_illust[:userAccount]
      end

      def ugoira_frame_delays
        api_ugoira[:frames].pluck("delay")
      end
    end
  end
end
