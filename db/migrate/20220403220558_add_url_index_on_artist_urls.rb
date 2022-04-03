class AddURLIndexOnArtistURLs < ActiveRecord::Migration[7.0]
  def change
    add_index :artist_urls, :url, opclass: :text_pattern_ops
  end
end
