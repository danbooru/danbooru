class CreateArtistCommentaryVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artist_commentary_versions do |t|
      t.integer :post_id, :null => false

      t.integer :updater_id, :null => false
      t.column :updater_ip_addr, "inet", :null => false

      t.text :original_title
      t.text :original_description
      t.text :translated_title
      t.text :translated_description

      t.timestamps
    end

    add_index :artist_commentary_versions, :post_id
    add_index :artist_commentary_versions, :updater_id
  end

  def self.down
    drop_table :artist_commentary_versions
  end
end
