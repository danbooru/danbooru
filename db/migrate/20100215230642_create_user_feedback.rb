class CreateUserFeedback < ActiveRecord::Migration[4.2]
  def self.up
    create_table :user_feedback do |t|
      t.column :user_id, :integer, :null => false
      t.column :creator_id, :integer, :null => false
      t.column :category, :string, :null => false
      t.column :body, :text, :null => false
      t.timestamps
    end

    add_index :user_feedback, :user_id
    add_index :user_feedback, :creator_id
  end

  def self.down
    drop_table :user_feedback
  end
end
