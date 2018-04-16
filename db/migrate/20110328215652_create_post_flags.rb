class CreatePostFlags < ActiveRecord::Migration[4.2]
  def self.up
    create_table :post_flags do |t|
      t.column :post_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :creator_ip_addr, :inet, :null => false
      t.column :reason, :text
      t.column :is_resolved, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :post_flags, :post_id
    add_index :post_flags, :creator_id
    add_index :post_flags, :creator_ip_addr
  end

  def self.down
    drop_table :post_flags
  end
end
