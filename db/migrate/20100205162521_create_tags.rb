class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :null => false
      t.column :post_count, :integer, :null => false, :default => 0
      t.column :view_count, :integer, :null => false, :default => 0
      t.column :category, :integer, :null => false, :default => 0
      t.column :related_tags, :text
      t.timestamps
    end
    
    add_index :tags, :name, :unique => true
  end

  def self.down
    drop_table :tags
  end
end
