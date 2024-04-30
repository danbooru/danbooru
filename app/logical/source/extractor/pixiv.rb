# frozen_string_literal: true

# @see Source::URL::Pixiv
module Source
  class Extractor
    class Pixiv < Source::Extractor
      def self.enabled?
        Danbooru.config.pixiv_phpsessid.present?
      end

      def self.to_dtext(text)
        return nil if text.nil?

        text = text.gsub(%r{<a href="https?://www\.pixiv\.net/(?:[a-z]+/)?artworks/([0-9]+)">illust/[0-9]+</a>}i) do |_match|
          pixiv_id = $1
          %(pixiv ##{pixiv_id} "»":[#{Routes.posts_path(tags: "pixiv:#{pixiv_id}")}])
        end

        text = text.gsub(%r{<a href="https?://www\.pixiv\.net/(?:[a-z]+/)?users/([0-9]+)">user/[0-9]+</a>}i) do |_match|
          member_id = $1
          profile_url = "https://www.pixiv.net/users/#{member_id}"

          artist_search_url = Routes.artists_path(search: { url_matches: profile_url })

          %("user/#{member_id}":[#{profile_url}] "»":[#{artist_search_url}])
        end

        DText.from_html(text, base_url: "https://www.pixiv.net", allowed_shortlinks: ["pixiv"]) do |element|
          # <a href="/jump.php?https%3A%2F%2Fshop.akbh.jp%2Fcollections%2Fvendors%3Fq%3D%25E7%258E%2589%25E4%25B9%2583%25E9%259C%25B2%26sort_by%3Dcreated-descending" target="_blank" rel="noopener">https://shop.akbh.jp/collections/vendors?q=%E7%8E%89%E4%B9%83%E9%9C%B2&amp;sort_by=created-descending</a>
          if element.name == "a" && element["href"]&.starts_with?("/jump.php")
            url = element["href"].delete_prefix("/jump.php?")
            element["href"] = Danbooru::URL.unescape(url)
          end
        end
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
        api_pages.pluck("urls").pluck("original").to_a
      end

      def page_url
        return nil if illust_id.blank?
        "https://www.pixiv.net/artworks/#{illust_id}"
      end

      def profile_url
        if api_illust[:userId].present?
          "https://www.pixiv.net/users/#{api_illust[:userId]}"
        elsif parsed_url.profile_url.present?
          parsed_url.profile_url
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
        api_illust[:userName]
      end

      def other_names
        other_names = [artist_name]
        other_names << moniker unless moniker&.starts_with?("user_")
        other_names.compact.uniq
      end

      def artist_commentary_title
        api_illust[:title]
      end

      def artist_commentary_desc
        api_illust[:description]
      end

      def tag_name
        moniker
      end

      def tags
        tags = api_illust.dig(:tags, :tags).to_a.map do |item|
          [item[:tag], "https://www.pixiv.net/tags/#{Danbooru::URL.escape(item[:tag])}/artworks"]
        end

        if api_illust["aiType"] == 2
          # XXX There's no way to search for posts with the AI flag on Pixiv. The "AI" tag is the closest equivalent.
          tags += [["AI", "https://www.pixiv.net/tags/AI/artworks"]]
        end

        if api_illust["request"].present?
          # XXX There's no way to search for posts commissioned via Pixiv Requests on Pixiv. The "依頼絵" ("commission") tag is the closest equivalent.
          tags += [["pixiv_commission", "https://www.pixiv.net/tags/依頼絵/artworks"]]
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

      def http
        super.cookies(PHPSESSID: Danbooru.config.pixiv_phpsessid)
      end

      memoize def api_illust
        # curl "https://www.pixiv.net/ajax/illust/87598468" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}")&.dig("body") || {}
      end

      memoize def api_pages
        # curl "https://www.pixiv.net/ajax/illust/87598468/pages" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/pages")&.dig("body") || {}
      end

      memoize def api_ugoira
        # curl "https://www.pixiv.net/ajax/illust/74932152/ugoira_meta" | jq
        http.cache(1.minute).parsed_get("https://www.pixiv.net/ajax/illust/#{illust_id}/ugoira_meta")&.dig("body") || {}
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
