# frozen_string_literal: true

# @see Source::URL::Inkbunny
# @see https://wiki.inkbunny.net/wiki/API
class Source::Extractor::Inkbunny < Source::Extractor
  def self.enabled?
    Danbooru.config.inkbunny_session.present?
  end

  def match?
    Source::URL::Inkbunny === parsed_url
  end

  def image_urls
    if parsed_url.image_url?
      [parsed_url.to_s]
    else
      submission[:files].to_a.pluck(:file_url_full)
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def artist_name
    submission[:username]
  end

  def profile_url
    "https://inkbunny.net/#{submission[:username]}" if submission.present?
  end

  def user_url
    "https://inkbunny.net/user.php?user_id=#{submission[:user_id]}" if submission.present?
  end

  def profile_urls
    [profile_url, user_url].compact
  end

  def artist_commentary_title
    submission[:title]
  end

  def artist_commentary_desc
    submission[:description_bbcode_parsed]
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc) do |element|
      if element.name == "table"
        mention = element.at ".widget_userNameSmall"
        if mention.present?
          element.name = "a"
          element[:href] = mention[:href]
          element.content = mention.content
        end
      end
    end&.strip
  end

  def tags
    submission[:keywords].to_a.map do |tag|
      [tag[:keyword_name], "https://inkbunny.net/search_process.php?keyword_id=#{tag[:keyword_id]}"]
    end
  end

  def submission_id
    parsed_url.submission_id || parsed_referer&.submission_id
  end

  def submission
    api_response[:submissions].to_a.first || {}
  end

  memoize def api_response
    return {} unless submission_id.present?

    params = {
      sid: Danbooru.config.inkbunny_session,
      show_description_bbcode_parsed: "yes",
      submission_ids: submission_id,
    }
    http.cache(1.minute).parsed_get("https://inkbunny.net/api_submissions.php", params: params) || {}
  end

end
