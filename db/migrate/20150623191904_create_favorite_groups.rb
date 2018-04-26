class CreateFavoriteGroups < ActiveRecord::Migration[4.2]
  def self.up
    create_table :favorite_groups do |t|
      t.text :name, :null => false
      t.integer :creator_id, :null => false
      t.text :post_ids, :null => false, :default => ""
      t.integer :post_count, :null => false, :default => 0

      t.timestamps
    end

    execute "create index index_favorite_groups_on_lower_name on favorite_groups (lower(name))"
    add_index :favorite_groups, :creator_id
  end

  def self.down
    drop_table :favorite_groups
  end
end
