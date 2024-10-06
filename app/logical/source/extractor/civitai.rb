# frozen_string_literal: true

# @see Source::URL::Civitai
class Source::Extractor
  class Civitai < Source::Extractor
    def match?
      Source::URL::Civitai === parsed_url
    end

    def image_urls
      if parsed_url&.full_image_url.present?
        [parsed_url.full_image_url]
      elsif image_uuids.present?
        image_uuids.map do |uuid|
          "https://image.civitai.com/xG1nkqKTMzGDvpLrqFT7WA/#{uuid}/original=true"
        end
      else
        []
      end
    end

    def page_url
      if image_id.present?
        "https://civitai.com/images/#{image_id}"
      elsif post_id.present?
        "https://civitai.com/posts/#{post_id}"
      end
    end

    def tags_api_url
      "https://civitai.com/api/trpc/tag.getVotableTags?input={%22json%22%3A{%22id%22%3A#{image_id}%2C%22type%22%3A%22image%22}}"
    end

    def artist_name
      user_json["username"]
    end

    def profile_url
      "https://civitai.com/user/#{artist_name}" if artist_name.present?
    end

    def tags
      return [] unless image_id.present?

      response = http.cache(1.minute).parsed_get(tags_api_url)
      response.dig("result", "data", "json").to_a.map do |tag|
        [tag["name"], "https://civitai.com/images?tags=#{tag['id']}"]
      end
    end

    memoize def html_response
      http.cache(1.minute).parsed_get(page_url)
    end

    memoize def next_queries
      JSON.parse(html_response&.at("#__NEXT_DATA__") || "{}").dig("props", "pageProps", "trpcState", "json", "queries").to_a
    end

    def post_json
      next_queries.dig(0, "state", "data").to_h
    end

    def image_json
      # Only on post pages.
      next_queries.dig(1, "state", "data").to_h if post_id.present?
    end

    def image_id
      parsed_url&.image_id || parsed_referer&.image_id
    end

    def post_id
      parsed_url&.post_id || parsed_referer&.post_id
    end

    memoize def image_uuids
      uuids = if image_json.present?
        image_json.dig("pages", 0, "items").to_a.map do |item|
          item['url']
        end
      else
        [post_json["url"]].compact
      end
    end

    def user_json
      post_json["user"].to_h
    end

    def artist_commentary_title
      post_json["title"]
    end

    def artist_commentary_desc
      post_json["detail"]
    end
  end
end
