# frozen_string_literal: true

# @see Source::Extractor::Reddit
class Source::Extractor::RedditComment < Source::Extractor::Reddit
  def image_urls
    page&.css("#embed-container faceplate-img").to_a.pluck("src").map do |url|
      Source::URL.parse(url).try(:full_image_url) || url
    end
  end

  def tags
    []
  end

  def artist_commentary_title
  end

  def artist_commentary_desc
    page&.at("#embed-container > div.relative")&.to_html
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://www.reddit.com")
  end

  def username
    page&.at('a[data-testid="user-name"]')&.text&.strip
  end

  def comment_id
    parsed_url.comment_id || parsed_referer&.comment_id
  end

  def embed_url
    "https://embed.reddit.com/r/#{subreddit}/comments/#{work_id}/comment/#{comment_id}" if subreddit.present? && work_id.present? && comment_id.present?
  end

  memoize def page
    http.cache(1.minute).parsed_get(embed_url)
  end
end
