# frozen_string_literal: true

# Find the artist entry for a given artist profile URL.
module ArtistFinder
  module_function

  # Find the artist for a given artist profile URL. May return multiple Artists
  # in the event of duplicate artist entries.
  #
  # Uses a path-stripping algorithm to find any artist URL that is a prefix
  # of the given URL.
  #
  # @param url [String] the artist profile URL
  # @return [Array<Artist>] the list of matching artists
  def find_artists(url)
    return Artist.none if url.blank?

    url = ArtistURL.normalize_url(url)

    # First try an exact match
    artists = Artist.active.joins(:urls).where(urls: { url: url }).load

    # If that fails, try removing the rightmost path component until we find an artist URL that matches the current URL.
    url = url.downcase.gsub(%r{\Ahttps?://|/\z}, "") # "https://example.com/A/B/C/" => "example.com/a/b/c"
    while artists.empty? && url != "."
      u = url.gsub("*", '\*') + "/*"
      artists += Artist.active.where(id: ArtistURL.normalized_url_like(u).select(:artist_id)).limit(10)

      # File.dirname("example.com/a/b/c") => "example.com/a/b"; File.dirname("example.com") => "."
      url = File.dirname(url)
    end

    # Assume no matches if we found too may duplicates.
    return Artist.none if artists.size >= 4

    Artist.where(id: artists.uniq.take(20))
  end
end
