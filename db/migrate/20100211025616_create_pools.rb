class CreatePools < ActiveRecord::Migration
  def self.up
    create_table :pools do |t|
      t.column :name, :string
      t.column :creator_id, :integer, :null => false
      t.column :description, :text
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :post_ids, :text, :null => false, :default => ""
      t.timestamps
    end
    
    add_index :pools, :name
    add_index :pools, :creator_id
    
    
    create_table :pool_versions do |t|
      t.column :pool_id, :integer
      t.column :post_ids, :text, :null => false, :default => ""
      t.column :updater_id, :integer, :null => false
      t.column :updater_ip_addr, "inet", :null => false
      t.timestamps
    end
    
    add_index :pool_versions, :pool_id
  end

  def self.down
    drop_table :pools
  end
end
