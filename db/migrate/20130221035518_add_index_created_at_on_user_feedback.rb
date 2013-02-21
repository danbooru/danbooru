class AddIndexCreatedAtOnUserFeedback < ActiveRecord::Migration
  def up
    add_index :user_feedback, :created_at
  end

  def down
    remove_index :user_feedback, :created_at
  end
end
