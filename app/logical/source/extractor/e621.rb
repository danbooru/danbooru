# frozen_string_literal: true

# @see Source::URL::E621
class Source::Extractor::E621 < Source::Extractor
  delegate :artist_commentary_title, :artist_commentary_desc, :dtext_artist_commentary_title, :dtext_artist_commentary_desc, to: :sub_extractor, allow_nil: true

  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif api_response.present?
      url = api_response.dig(:files, :original, :url)

      if url.nil?
        # young -rating:s
        md5 = api_response.dig(:files, :meta, :md5)
        ext = api_response.dig(:files, :meta, :ext)
        url = "https://static1.e621.net/data/#{md5[0..1]}/#{md5[2..3]}/#{md5}.#{ext}"
      end

      [url]
    else
      []
    end
  end

  def page_url
    parsed_url.page_url || parsed_referer&.page_url
  end

  def tags
    return [] if api_response.blank?

    tags = api_response[:tags].to_a + ["rating:#{api_response[:rating]}"]
    tags.map do |tag|
      url = "https://e621.net/posts?tags=#{Danbooru::URL.escape(tag)}"
      [tag, url]
    end
  end

  def profile_url
    profile_urls.first
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
    sub_extractor&.username || uploader_linked_artists.pick(:name) || super
  end

  # The artists tagged on the post that are linked to the uploader's account.
  memoize def uploader_linked_artists
    return [] if api_response[:uploader_id].blank?

    url = "https://e621.net/artists.json?search[linked_user_id]=#{Danbooru::URL.escape(api_response[:uploader_id].to_s)}"
    artists = request(url).to_a.map { |artist| artist.to_h.with_indifferent_access }
    artists.select { |artist| artist[:name].in?(api_response[:tags].to_a) }
  end

  memoize def api_response
    return {} if page_url.blank?

    response = request(page_url)
    response.is_a?(Hash) ? response : {}
  end

  def request(url, **)
    http.cache(1.minute).headers(accept: "application/json").parsed_get(url)
  end

  def sub_extractor
    return nil if parent_extractor.present?

    url = api_response[:sources].to_a.filter_map do |url|
      url = Source::URL.parse(url)
      url if url&.page_url.present?
    end.first

    @sub_extractor ||= Source::Extractor.find(url, default_extractor: nil, parent_extractor: self)
  end
end
