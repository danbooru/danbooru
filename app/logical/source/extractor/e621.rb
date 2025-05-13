# frozen_string_literal: true

# @see Source::URL::E621
class Source::Extractor::E621 < Source::Extractor
  delegate :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif api_response.present?
      url = api_response.dig(:file, :url)

      if url.nil?
        # young -rating:s
        md5 = api_response.dig(:file, :md5)
        ext = api_response.dig(:file, :ext)
        url = "https://static1.e621.net/data/#{md5[0..1]}/#{md5[2..3]}/#{md5}.#{ext}"
      end

      [url]
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def tags
    return [] if api_response.blank?

    tags = api_response[:tags].to_h.values.reduce(:+) + ["rating:#{api_response[:rating]}"]
    tags.map do |tag|
      url = "https://e621.net/posts?tags=#{Danbooru::URL.escape(tag)}"
      [tag, url]
    end
  end

  def profile_urls
    linked_urls = uploader_linked_artists.flat_map do |artist|
      user_url = "https://e621.net/users/#{artist[:linked_user_id]}"
      external_urls = artist[:urls].pluck(:url)
      [user_url, *external_urls]
    end
    [*linked_urls, *sub_extractor&.profile_urls].compact_blank.uniq
  end

  def tag_name
    sub_extractor&.tag_name || super
  end

  def artist_name
    sub_extractor&.artist_name || super
  end

  def display_name
    sub_extractor&.display_name || super
  end

  def username
    sub_extractor&.username || uploader_linked_artists.pluck(:name).first || super
  end

  # https://github.com/e621ng/e621ng/blob/59f5fda98f0877190bb5816f766c17bd6b9affb9/app/models/post.rb#L1710
  memoize def uploader_linked_artists
    api_response.dig(:tags, :artist).map do |artist_name|
      url = "https://e621.net/artists.json?search[name]=#{Danbooru::URL.escape(artist_name)}"
      request(url)&.first.to_h.with_indifferent_access
    end.select do |artist|
      artist[:linked_user_id] == api_response[:uploader_id]
    end
  end

  memoize def api_response
    return {} if page_url.blank?

    request(page_url)&.dig(:post) || {}
  end

  def request(url, **params)
    http.cache(1.minute).headers(accept: "application/json").parsed_get(url)
  end

  def sub_extractor
    return nil if parent_extractor.present?

    url = api_response[:sources].filter_map do |url|
      Source::URL.parse url
    end.select do |url|
      url.page_url.present?
    end.first

    @sub_extractor ||= Source::Extractor.find(url, default_extractor: nil, parent_extractor: self)
  end
end
