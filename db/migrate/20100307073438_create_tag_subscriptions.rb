class CreateTagSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :tag_subscriptions do |t|
      t.column :owner_id, :integer, :null => false
      t.column :name, :string, :null => false
      t.column :tag_query, :string, :null => false
      t.column :post_ids, :text, :null => false
      t.column :is_visible_on_profile, :boolean, :null => false, :default => true
      t.timestamps
    end
    
    add_index :tag_subscriptions, :owner_id
    add_index :tag_subscriptions, :name
  end

  def self.down
    drop_table :tag_subscriptions
  end
end
