# frozen_string_literal: true

# @see Source::URL::Patreon
class Source::Extractor::Patreon < Source::Extractor
  def image_urls
    # Try to get the full image URL from the API in case this is a sample image or an expired URL.
    if parsed_url.image_url? && image_url_from_api.present?
      [image_url_from_api]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      image_urls_from_api
    end
  end

  memoize def image_urls_from_api
    # The list of media objects can contain duplicate files. This happens for old posts with inline images where the
    # first image was made the post's cover image. These files have unique URLs despite being MD5-identical, so we
    # filter them out by their name/size/dimensions. Ex: https://www.patreon.com/posts/sailormoonredraw-37219108.
    unique_media = media.uniq { _1.values_at(*%w[file_name dimensions size_bytes mimetype]) }
    unique_media.pluck("display").pluck("url").compact
  end

  memoize def image_url_from_api
    return nil unless parsed_url.media_hash.present?
    image_urls_from_api.find { |url| Source::URL.parse(url).try(:media_hash) == parsed_url.media_hash }
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://www.patreon.com/#{username}" if username.present?
  end

  def profile_urls
    [profile_url, ("https://www.patreon.com/user?u=#{user_id}" if user_id.present?)].compact
  end

  def artist_name
    user.dig("attributes", "full_name")&.strip
  end

  def tag_name
    username.to_s.downcase.gsub(/\A_+|_+\z/, "").squeeze("_").presence
  end

  def other_names
    [artist_name, username].compact_blank.uniq(&:downcase)
  end

  def tags
    api_response["included"].to_a.select { _1["type"] == "post_tag" }.pluck("attributes").pluck("value").map do |tag|
      [tag, "#{profile_url}/posts?filters[tag]=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    post["title"]
  end

  def artist_commentary_desc
    if post["post_type"] == "poll"
      <<~EOS
        #{post["content"]}

        <h6>Poll: #{CGI.escapeHTML(poll["question_text"])}</h6>

        <ul>
          #{poll_choices.pluck("text_content").map { |choice| "<li>#{CGI.escapeHTML(choice)}</li>" }.join("\n")}
        </ul>
      EOS
    else
      post["content"]
    end
  end

  def dtext_artist_commentary_desc
    # Ignore commentary if it only contains inline images with no actual text.
    return "" if post["content"].to_s.parse_html.text.blank?

    DText.from_html(artist_commentary_desc, base_url: "https://www.patreon.com") do |element|
      if element.name == "img"
        element.name = "a"
        element.content = "[image]"
        element["href"] = url
      end
    end
  end

  def post
    api_response.dig("data", "attributes") || {}
  end

  def user
    api_response["included"].to_a.find { _1["type"] == "user" } || {}
  end

  def media
    api_response["included"].to_a.select { _1["type"] == "media" }.pluck("attributes")
  end

  def poll
    api_response["included"].to_a.find { _1["type"] == "poll" }&.dig("attributes") || {}
  end

  def poll_choices
    api_response["included"].to_a.select { _1["type"] == "poll_choice" }.pluck("attributes").sort_by { _1["position"] }
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || user["id"]
  end

  def username
    parsed_url.username || parsed_referer&.username || user.dig("attributes", "vanity")
  end

  memoize def api_response
    url = "https://www.patreon.com/api/posts/#{post_id}?include=media,images,video,audio,attachments,user,user_defined_tags,poll.choices" if post_id.present?
    http.cache(1.minute).parsed_get(url) || {}
  end

  def http_downloader
    # Don't spoof the referer as the URL itself because that will cause video posts served from https://stream.mux.com to fail.
    super.headers(Referer: "https://www.patreon.com")
  end
end
