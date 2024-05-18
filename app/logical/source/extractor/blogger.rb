# frozen_string_literal: true

# @see Source::URL::Blogger
class Source::Extractor::Blogger < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    else
      artist_commentary_desc.to_s.parse_html.css("img").map do |img|
        url = img["data-src"] || img["src"]
        Source::URL.parse(url).try(:full_image_url) || url
      end
    end
  end

  def profile_url
    blog_url
  end

  def profile_urls
    [blog_url, blog_author_url].compact.uniq
  end

  def display_name
    post.dig("author", "displayName") || page.dig("author", "displayName")
  end

  def username
    blog_name
  end

  def tags
    return [] unless blog_url.present?

    post["labels"].to_a.map do |label|
      [label, "#{blog_url}/search/label/#{Danbooru::URL.escape(label)}"]
    end
  end

  def artist_commentary_title
    post["title"] || page["title"]
  end

  def artist_commentary_desc
    post["content"] || page["content"]
  end

  def dtext_artist_commentary_desc
    # Ignore commentary if it only contains images with no actual text.
    return "" if artist_commentary_desc.to_s.parse_html.text.blank?

    DText.from_html(artist_commentary_desc, base_url: blog_url) do |element|
      case element.name
      in "div" unless element.at("div").present?
        element.name = "p"

      in "a" if element.at("img").present?
        url = element.at("img").attr("src").then { |url| Source::URL.parse(url).try(:full_image_url) || url }
        element.name = "p"
        element.inner_html = %{<a href="#{url}">[image]</a>}

      else
        nil
      end
    end
  end

  def user_id
    parsed_url.user_id || parsed_referer&.user_id || post.dig("author", "id") || page.dig("author", "id")
  end

  def blog_name
    parsed_url.blog_name || parsed_referer&.blog_name
  end

  def page_name
    parsed_url.page_name || parsed_referer&.page_name
  end

  def blog_url
    parsed_url.blog_url || parsed_referer&.blog_url
  end

  def blog_author_url
    "https://www.blogger.com/profile/#{user_id}" if user_id.present?
  end

  memoize def blog
    # https://developers.google.com/blogger/docs/3.0/reference/blogs/getByUrl
    # curl 'https://www.googleapis.com/blogger/v3/blogs/byurl?key=AIzaSyCN9ax34oMMyM07g_M-5pjeDp_312eITK8&url=https://benbotport.blogspot.com'
    url = "https://www.googleapis.com/blogger/v3/blogs/byurl?key=#{api_key}&url=#{blog_url}" if api_key.present? && blog_url.present?
    http.cache(1.minute).parsed_get(url) || {}
  end

  memoize def post
    # https://developers.google.com/blogger/docs/3.0/reference/posts/getByPath
    # curl 'https://www.googleapis.com/blogger/v3/blogs/4063061489843530714/posts/bypath?key=AIzaSyCN9ax34oMMyM07g_M-5pjeDp_312eITK8&path=/2011/06/mass-effect-2.html'
    blog_path = Source::URL.parse(page_url)&.path
    url = "https://www.googleapis.com/blogger/v3/blogs/#{blog["id"]}/posts/bypath?key=#{api_key}&path=#{blog_path}" if api_key.present? && blog_path.present? && blog["id"].present?
    http.cache(1.minute).parsed_get(url) || {}
  end

  memoize def pages
    # https://developers.google.com/blogger/docs/3.0/reference/pages/list
    # curl 'https://www.googleapis.com/blogger/v3/blogs/2199400548823551998/pages?key=AIzaSyCN9ax34oMMyM07g_M-5pjeDp_312eITK8
    url = "https://www.googleapis.com/blogger/v3/blogs/#{blog["id"]}/pages?key=#{api_key}" if api_key.present? && blog["id"].present?
    http.cache(1.minute).parsed_get(url)&.dig(:items) || []
  end

  memoize def page
    pages.find { |page| Source::URL.parse(page["url"]).try(:page_name) == page_name } || {}
  end

  def api_key
    Danbooru.config.blogger_api_key
  end
end
