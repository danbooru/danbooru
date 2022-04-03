class MakeNormalizedURLNullableOnArtistURLs < ActiveRecord::Migration[7.0]
  def change
    change_column_null :artist_urls, :normalized_url, true
  end
end
