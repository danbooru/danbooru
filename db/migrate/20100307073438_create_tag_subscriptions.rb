class CreateTagSubscriptions < ActiveRecord::Migration[4.2]
  def self.up
    create_table :tag_subscriptions do |t|
      t.column :creator_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :tag_query, :string, :null => false
      t.column :post_ids, :text, :null => false
      t.column :is_public, :boolean, :null => false, :default => true
      t.column :last_accessed_at, :datetime
      t.column :is_opted_in, :boolean, :null => false, :default => false
      t.timestamps
    end

    add_index :tag_subscriptions, :creator_id
    add_index :tag_subscriptions, :name
  end

  def self.down
    drop_table :tag_subscriptions
  end
end
