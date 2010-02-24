class CreatePostModerationDetails < ActiveRecord::Migration
  def self.up
    create_table :post_moderation_details do |t|
      t.column :user_id, :integer, :null => false
      t.column :post_id, :integer, :null => false
      t.timestamps
    end
    
    add_index :post_moderation_details, :user_id
    add_index :post_moderation_details, :post_id
  end

  def self.down
    drop_table :post_moderation_details
  end
end
