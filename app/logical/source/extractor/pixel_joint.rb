# frozen_string_literal: true

# @see Source::URL::PixelJoint
class Source::Extractor::PixelJoint < Source::Extractor
  def image_urls
    if parsed_url.image_url?
      [url]
    else
      # <img id='mainimg' src="/files/icons/full/cat__r16042437891.png" alt="cat" width='200' height='200' border='0' />
      [page&.at("#mainimg")&.[]("src")].compact.map { |src| URI.join("https://pixeljoint.com", src).to_s }
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  # <a href='/p/243789.htm' onmouseover="..." target="_top">CJDMAX</a>
  memoize def artist_link
    page&.search("#leftblockspan a[href^='/p/']")&.find { |link| link.text.present? }
  end

  def profile_url
    if artist_link.present?
      "https://pixeljoint.com#{artist_link["href"]}"
    else
      parsed_url.profile_url || parsed_referer&.profile_url
    end
  end

  def username
    artist_link&.text&.strip
  end

  def artist_commentary_title
    page&.at("#container h1")&.text&.strip
  end

  # <ul class='tags'><li><a href='/pixels/new_icons.asp?ob='>More from the gallery</a></li><li><a href='/pixelart/2003/Miscellaneous.htm'>Misc pixel art</a></li></ul>
  def tags
    page&.search("ul.tags a[href^='/pixelart/']").to_a.map do |link|
      [link.text.delete_suffix(" pixel art"), "https://pixeljoint.com#{link["href"]}"]
    end
  end

  memoize def page
    # Pixel Joint shows a Cloudflare challenge to browser user agents.
    parsed_get(page_url, headers: { "User-Agent": "#{Danbooru.config.canonical_app_name}/#{Rails.application.config.x.git_hash}" })
  end
end
