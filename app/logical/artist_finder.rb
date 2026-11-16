# frozen_string_literal: true

# Find the artist entry for a given artist profile URL.
module ArtistFinder
  module_function

  # If a URL matches this many artists or more, assume it's a generic URL and return no matches for it.
  TOO_MANY_DUPLICATES = 4

  # Find the artists for the given artist profile URLs. May return multiple Artists for a URL in the event of duplicate
  # artist entries.
  #
  # Uses a path-stripping algorithm to find any artist URL that is a prefix of the given URL. If there's no exact match
  # for "example.com/a/b", then we look for artist URLs starting with "example.com/a/b/", then "example.com/a/", then
  # "example.com/", and use the first of these that matches anything.
  #
  # All URLs are looked up together in two queries, no matter how many URLs there are or how deep their paths go: one
  # query for the exact matches, and one for every prefix of every URL without an exact match.
  #
  # @param urls [String, Array<String>] the artist profile URLs
  # @return [ActiveRecord::Relation<Artist>] the list of matching artists
  def find_artists(urls)
    # Normalize the URLs the same way artist URLs are normalized when they're saved, so they can be compared directly.
    urls = Array.wrap(urls).compact_blank.map { ArtistURL.normalize_url(it) }.uniq
    return Artist.none if urls.empty?

    # Step 1: Find artists with exactly the same URL.
    # Returns a hash of each URL to its matching artist IDs, e.g. { "https://example.com/a" => [1, 2] }.
    exact_matches = Artist.active.joins(:urls).where(urls: { url: urls }).pluck("urls.url", :id)
    exact_matches = exact_matches.group_by(&:first).transform_values { |rows| rows.map(&:second) }

    # Step 2: List the prefixes of each URL that didn't have an exact match, from longest to shortest.
    # Returns a hash like { "https://example.com/A/B/" => ["example.com/a/b/", "example.com/a/", "example.com/"] }.
    url_prefixes = (urls - exact_matches.keys).index_with do |url|
      # "https://example.com/A/B/" => "example.com/a/b". This matches how the URL index normalizes artist URLs.
      path = url.downcase.gsub(%r{\Ahttps?://|/\z}, "")

      # ["example.com/a/b", "example.com/a", "example.com"]. When there's no parent left, File.dirname returns "." (or
      # "/" for paths starting with "/", which would otherwise loop forever), so we stop there.
      paths = Enumerator.produce(path) { File.dirname(it) }.take_while { it != "." && it != "/" }

      # Add a trailing slash, so that "example.com/a/" matches "example.com/a/b", but not "example.com/abc". It still
      # matches "example.com/a", because the URL index also adds a trailing slash to artist URLs.
      paths.map { "#{it}/" }
    end

    # Step 3: Look up every prefix of every URL in one query.
    # Returns a hash of each prefix to the IDs of up to 10 artists with a URL starting with it, e.g. { "example.com/a/" => [3] }.
    prefix_matches = find_artist_ids_by_prefix(url_prefixes.values.flatten.uniq)

    # Step 4: Pick the matching artists for each URL.
    artist_ids = urls.flat_map do |url|
      # Use the exact matches if there are any. Otherwise use the longest prefix that matched anything.
      ids = exact_matches[url] || url_prefixes[url].lazy.filter_map { prefix_matches[it] }.first || []

      # Too many matches usually means a generic URL, like a site's homepage, so ignore them.
      (ids.size >= TOO_MANY_DUPLICATES) ? [] : ids.uniq.take(20)
    end

    Artist.where(id: artist_ids)
  end

  # Find up to 10 active artists with a URL starting with each prefix, in one query.
  #
  # The prefix match is written as a range (`url ~>=~ 'a.com/' AND url ~<~ 'a.com0'`) instead of a `LIKE`, because
  # Postgres can only use the URL index for a `LIKE` with a constant pattern, not one taken from another table. Every
  # prefix ends with "/", and "0" is the next character after "/", so the range covers exactly the URLs with that prefix.
  #
  # @param prefixes [Array<String>] normalized URL prefixes ending in "/", like "example.com/a/"
  # @return [Hash<String, Array<Integer>>] each prefix mapped to the artist IDs of its matching URLs
  def find_artist_ids_by_prefix(prefixes)
    return {} if prefixes.empty?

    normalized_url = "regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/'" # this is indexed

    # A table with one row per prefix and the range it covers, e.g. ("example.com/a/", "example.com/a0").
    prefixes_table = ArtistURL.sanitize_sql_array(["unnest(ARRAY[:lo]::text[], ARRAY[:hi]::text[]) AS prefixes(lo, hi)", { lo: prefixes, hi: prefixes.map { "#{it.chop}0" }}])

    # The artist URLs of active artists in one prefix's range. The `LIMIT 10` applies to each prefix separately.
    matches = ArtistURL.joins(:artist).merge(Artist.active).where("#{normalized_url} ~>=~ prefixes.lo AND #{normalized_url} ~<~ prefixes.hi").limit(10)

    # `CROSS JOIN LATERAL` runs the `matches` subquery once for each prefix row, with `prefixes.lo` and `prefixes.hi`
    # set to that row's values. Each run is an index range scan, so this works like one query per prefix, but in a
    # single round trip. Returns rows of [prefix, artist_id].
    rows = ArtistURL.unscoped.from(prefixes_table).joins("CROSS JOIN LATERAL (#{matches.select(:artist_id).to_sql}) AS matches").pluck("prefixes.lo", "matches.artist_id")
    rows.group_by(&:first).transform_values { |prefix_rows| prefix_rows.map(&:second) }
  end
end
