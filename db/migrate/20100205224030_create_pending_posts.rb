class CreatePendingPosts < ActiveRecord::Migration
  def self.up
    create_table :pending_posts do |t|
      t.timestamps
      t.column :source, :string
      t.column :rating, :character, :null => false
      t.column :uploader_id, :integer, :null => false
      t.column :uploader_ip_addr, "inet", :null => false
      t.column :tag_string, :text, :null => false
      t.column :status, :string, :null => false, :default => "pending"
      t.column :post_id, :integer
    end
  end

  def self.down
    drop_table :pending_posts
  end
end
