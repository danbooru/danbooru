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

        DText.from_html(text) do |element|
          if element.name == "a" && element["href"].match?(%r!\A/jump\.php\?!)
            element["href"] = Addressable::URI.heuristic_parse(element["href"]).normalized_query
          end
        end
      end

      def match?
        Source::URL::Pixiv === parsed_url
      end

      def image_urls
        if is_ugoira?
          [api_ugoira[:originalSrc]]
        # If it's a full image URL, then use it as-is instead of looking it up in the API, because it could be the
        # original version of an image that has since been revised.
        elsif parsed_url.full_image_url?
          [parsed_url.to_s]
        # If it's a sample image URL, then try to find the full image URL in the API if possible.
        elsif parsed_url.image_url? && parsed_url.page && original_urls.present?
          [original_urls[parsed_url.page]]
        # Otherwise if it's a sample image and we can't get the full image from the API (presumably because the post
        # has been deleted), just use the sample version as is.
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

      def dtext_artist_commentary_desc
        commentary = super
        return nil if commentary.nil?

        if commission_desc.present?
          commentary << "\n\n[tn]\nSource: #{page_url}\n[/tn]\n\n"
          commentary << dtext_commission_desc
          commentary << "\n\n[tn]\nSource: #{commission_url}\n[/tn]"
        end

        commentary
      end

      def commission_id
        api_illust.dig("request", "request", "requestId")
      end

      def commission_url
        return nil if commission_id.blank?
        "https://www.pixiv.net/requests/#{commission_id}"
      end

      def commission_desc
        api_illust.dig("request", "request", "requestProposal", "requestOriginalProposal")
      end

      def dtext_commission_desc
        text = commission_desc
        return nil if text.nil?

        text = text.gsub(%r{(?<=\s|\A)https?://www\.pixiv\.net/(?:[a-z]+/)?artworks/([0-9]+)(?=\s|\z)}i) do |_match|
          pixiv_id = $1
          %(<a href="https://www.pixiv.net/artworks/#{illust_id}">illust/#{illust_id}</a>)
        end

        text = text.gsub(%r{(?<=\s|\A)https?://www\.pixiv\.net/(?:[a-z]+/)?users/([0-9]+)(?=\s|\z)}i) do |_match|
          member_id = $1
          %(<a href="https://www.pixiv.net/users/#{member_id}">user/#{member_id}</a>)
        end

        self.class.to_dtext text
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

      def illust_id
        parsed_url.work_id || parsed_referer&.work_id
      end

      def api_client
        PixivAjaxClient.new(Danbooru.config.pixiv_phpsessid, http: http)
      end

      def api_illust
        api_client.illust(illust_id)
      end

      def api_pages
        api_client.pages(illust_id)
      end

      def api_ugoira
        api_client.ugoira_meta(illust_id)
      end

      def moniker
        parsed_url.username || api_illust[:userAccount]
      end

      def ugoira_frame_delays
        api_ugoira[:frames].pluck("delay")
      end

      memoize :illust_id, :api_client, :api_illust, :api_pages, :api_ugoira
    end
  end
end
