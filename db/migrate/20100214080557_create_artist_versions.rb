class CreateArtistVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artist_versions do |t|
      t.column :artist_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :other_names, :text
      t.column :group_name, :string
      t.column :url_string, :text
      t.column :is_banned, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :artist_versions, :artist_id
    add_index :artist_versions, :name
    add_index :artist_versions, :updater_id
  end

  def self.down
    drop_table :artist_versions
  end
end
