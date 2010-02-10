class CreatePostVersions < ActiveRecord::Migration
  def self.up
    create_table :post_versions do |t|
      t.timestamps
      
      # Post
      t.column :post_id, :integer, :null => false
      
      # Versioned
      t.column :source, :string
      t.column :rating, :character, :null => false, :default => 'q'
      t.column :tag_string, :text, :null => false

      # Updater
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
    end
    
    add_index :post_versions, :post_id
    add_index :post_versions, :updater_id
  end

  def self.down
    drop_table :post_versions
  end
end
