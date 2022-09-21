class DropNormalizedURLFromArtistURLs < ActiveRecord::Migration[7.0]
  def change
    remove_column :artist_urls, :normalized_url, :text
  end
end
