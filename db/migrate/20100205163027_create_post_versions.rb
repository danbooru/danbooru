class CreatePostVersions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :post_versions do |t|
      t.timestamps

      t.column :post_id, :integer, :null => false
      t.column :tags, :text, :null => false, :default => ""
      t.column :rating, :char
      t.column :parent_id, :integer
      t.column :source, :text
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
    end

    add_index :post_versions, :post_id
    add_index :post_versions, :updater_id
    add_index :post_versions, :updater_ip_addr
  end

  def self.down
    drop_table :post_versions
  end
end
