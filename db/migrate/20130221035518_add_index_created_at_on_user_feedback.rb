class AddIndexCreatedAtOnUserFeedback < ActiveRecord::Migration
  def up
    execute "set statement_timeout = 0"
    add_index :user_feedback, :created_at
  end

  def down
    execute "set statement_timeout = 0"
    remove_index :user_feedback, :created_at
  end
end
