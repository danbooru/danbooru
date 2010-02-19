class CreateUserFeedback < ActiveRecord::Migration
  def self.up
    create_table :user_feedback do |t|
      t.column :user_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :is_positive, :boolean, :null => false
      t.column :body, :text, :null => false
      t.timestamps
    end
    
    add_index :user_feedback, :user_id
  end

  def self.down
    drop_table :user_feedback
  end
end
