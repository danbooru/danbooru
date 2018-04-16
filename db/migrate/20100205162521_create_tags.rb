class CreateTags < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tags do |t|
      t.column :name, :string, :null => false
      t.column :post_count, :integer, :null => false, :default => 0
      t.column :category, :integer, :null => false, :default => 0
      t.column :related_tags, :text
      t.column :related_tags_updated_at, :datetime
      t.timestamps
    end

    add_index :tags, :name, :unique => true
    execute "create index index_tags_on_name_pattern on tags (name text_pattern_ops)"
  end

  def self.down
    drop_table :tags
  end
end
