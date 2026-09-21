# frozen_string_literal: true

# @see Source::URL::Duitang
class Source::Extractor::Duitang < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    else
      [blog.dig(:photo, :path)].compact
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def profile_url
    "https://www.duitang.com/people/?id=#{user_id}" if user_id.present?
  end

  def display_name
    blog.dig(:sender, :username)
  end

  def user_id
    blog.dig(:sender, :id) || parsed_url.user_id || parsed_referer&.user_id
  end

  def published_at
    Time.at(blog[:add_datetime_ts]).utc if blog[:add_datetime_ts].present?
  end

  def tags
    blog[:tags].to_a.pluck(:name).map do |name|
      [name, "https://www.duitang.com/search/?kw=#{Addressable::URI.encode_component(name)}&type=feed"]
    end
  end

  def artist_commentary_desc
    blog[:msg]
  end

  def blog_id
    parsed_url.blog_id || parsed_referer&.blog_id
  end

  memoize def blog
    return {} if blog_id.blank?

    http.cache(1.minute).parsed_get("https://www.duitang.com/napi/blog/detail/?blog_id=#{blog_id}&include_fields=tags")&.dig(:data) || {}
  end
end
