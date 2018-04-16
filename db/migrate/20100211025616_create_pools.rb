class CreatePools < ActiveRecord::Migration[4.2]
  def self.up
    create_table :pools do |t|
      t.column :name, :string
      t.column :creator_id, :integer, :null => false
      t.column :description, :text
      t.column :is_active, :boolean, :null => false, :default => true
      t.column :post_ids, :text, :null => false, :default => ""
      t.column :post_count, :integer, :null => false, :default => 0
      t.column :is_deleted, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :pools, :name
    add_index :pools, :creator_id
  end

  def self.down
    drop_table :pools
  end
end
