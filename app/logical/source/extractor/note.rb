# frozen_string_literal: true

# @see Source::URL::Note
class Source::Extractor::Note < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      api_response["pictures"].to_a.pluck("url").map do |url|
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def profile_url
    parsed_url.profile_url || parsed_referer&.profile_url
  end

  def display_name
    api_response.dig("user", "nickname")
  end

  def username
    parsed_url.username || parsed_referer&.username || api_response.dig("user", "urlname")
  end

  def tags
    api_response["hashtag_notes"].to_a.pluck("hashtag").pluck("name").map do |tag|
      tag = tag.delete_prefix("#")
      [tag, "https://note.com/hashtag/#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    api_response["name"]
  end

  def artist_commentary_desc
    case api_response["type"]
    when "ImageNote"
      api_response["pictures"].to_json
    when "TextNote"
      api_response["body"]
    end
  end

  def dtext_artist_commentary_desc
    case api_response["type"]
    when "ImageNote"
      # If there are multiple pictures and at least one has a caption, then include the images with the captions.
      if api_response["pictures"]&.many? && api_response["pictures"].any? { _1["caption"].present? }
        api_response["pictures"].to_a.map do |picture|
          <<~EOS.chomp
            "[image]":[#{picture["url"]}]

            #{DText.from_plaintext(picture["caption"])}
          EOS
        end.join("\n\n")
      else
        DText.from_plaintext(api_response.dig("pictures", 0, "caption"))
      end
    when "TextNote"
      DText.from_html(artist_commentary_desc, base_url: "https://note.com") do |element|
        case element.name
        in "img"
          element["alt"] = "[image]"
        in "figure" if element["embedded-service"].present? && element["data-src"].present?
          element.name = "p"
          element.inner_html = %{<a href="#{element["data-src"]}">#{element["data-src"]}</a>}
        in "figure"
          element.name = "p"
        else
          nil
        end
      end
    else
      ""
    end
  end

  def post_id
    parsed_url.post_id || parsed_referer&.post_id
  end

  memoize def api_response
    return {} unless post_id.present?

    # curl https://note.com/api/v3/notes/n708975a045af | jq
    http.cache(1.minute).parsed_get("https://note.com/api/v3/notes/#{post_id}")&.dig("data") || {}
  end
end
