class AddLowerURLIndexToArtistURLs < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    # This index is used by the ArtistFinder.
    #
    # regexp_replace(lower('https://www.twitter.com/DanbooruBot'), '^https?://|/$', '', 'g') || '/'
    # => 'www.twitter.com/danboorubot/'
    add_index :artist_urls, "(regexp_replace(lower(artist_urls.url), '^https?://|/$', '', 'g') || '/') text_pattern_ops", name: :index_artist_urls_on_regexp_replace_lower_url, algorithm: :concurrently
  end
end
