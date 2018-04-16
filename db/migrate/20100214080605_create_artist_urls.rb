class CreateArtistUrls < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artist_urls do |t|
      t.column :artist_id, :integer, :null => false
      t.column :url, :text, :null => false
      t.column :normalized_url, :text, :null => false
      t.timestamps
    end

    add_index :artist_urls, :artist_id
    add_index :artist_urls, :normalized_url
    add_index :artist_urls, :url

    execute "create index index_artist_urls_on_url_pattern on artist_urls (url text_pattern_ops)"
    execute "create index index_artist_urls_on_normalized_url_pattern on artist_urls (normalized_url text_pattern_ops)"
  end

  def self.down
    drop_table :artist_urls
  end
end
