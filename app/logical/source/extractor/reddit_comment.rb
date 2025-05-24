# frozen_string_literal: true

# @see Source::Extractor::Reddit
class Source::Extractor::RedditComment < Source::Extractor::Reddit
  def image_urls
    comment["media_metadata"].to_h.map do |_, media|
      Source::URL.parse(media.dig("s", "u")).full_image_url
    end
  end

  def tags
    []
  end

  def artist_commentary_title
  end

  def html_artist_commentary_desc
    CGI.unescapeHTML(comment["body_html"])
  end

  def dtext_artist_commentary_desc
    DText.from_html(html_artist_commentary_desc, base_url: "https://www.reddit.com") do |element|
      case element.name
      in "a"
        # Remove embedded images (if they appear in image_urls)
        if element[:href] && image_urls.include?(Source::URL.parse(element[:href]).full_image_url)
          element.content = ""
        end
      in "span"
        # Transform spoiler tags
        if element.classes.include?("md-spoiler-text")
          element.name = "inline-spoiler"
        end
      else
        nil
      end
    end
  end

  def username
    comment["author"]
  end

  def comment_id
    parsed_url.comment_id || parsed_referer&.comment_id
  end

  memoize def comment
    find_comment(comment_id)
  end
end
