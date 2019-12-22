class AddTrigramIndexToArtistUrls < ActiveRecord::Migration[5.2]
  def change
    execute "set statement_timeout = 0"

    change_table :artist_urls do |t|
      t.remove_index column: :url, name: :index_artist_urls_on_url
      t.remove_index column: :url, name: :index_artist_urls_on_url_pattern, opclass: :text_pattern_ops
      t.remove_index column: :normalized_url, name: :index_artist_urls_on_normalized_url

      t.index :url, name: :index_artist_urls_on_url_trgm, using: :gin, opclass: :gin_trgm_ops
      t.index :normalized_url, name: :index_artist_urls_on_normalized_url_trgm, using: :gin, opclass: :gin_trgm_ops
    end
  end
end
