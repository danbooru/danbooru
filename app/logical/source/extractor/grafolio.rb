# frozen_string_literal: true

# @see Source::URL::Grafolio
class Source::Extractor::Grafolio < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      path = project.dig(:mainImage, :path) # "real/07ac3f44283843c3af4b02cf5609c89a/IMAGE/ae3c63cb-0e33-4f09-ad7a-21d5182f8883.jpg"
      image_url = "https://files.grafolio.ogq.me/#{path}" if path.present?
      [image_url].compact
    end
  end

  def profile_url
    "https://grafolio.ogq.me/profile/#{username}/projects" if username.present?
  end

  def username
    project.dig(:owner, :nickname) || parsed_url.username || parsed_referer&.username
  end

  def tags
    project[:tags].to_a.map do |tag|
      [tag, "https://grafolio.ogq.me/search/projects?q=#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    project[:title]
  end

  def artist_commentary_desc
    project[:contentBlocks].to_json
  end

  def dtext_artist_commentary_desc
    DText.from_html(html_artist_commentary_desc, base_url: "https://grafolio.ogq.me")
  end

  def html_artist_commentary_desc
    project[:contentBlocks].to_a.map do |block|
      case block[:contentType]
      in "IMAGE"
        "" # Ignored
      in "TEXT"
        block.dig(:text, :html)
      else
        ""
      end
    end.join
  end

  def project_id
    parsed_url.project_id || parsed_referer&.project_id
  end

  memoize def project
    api_url = "https://grafolio.ogq.me/api/projects/single/#{project_id}" if project_id.present?
    http.cache(1.minute).parsed_get(api_url) || {}
  end
end
