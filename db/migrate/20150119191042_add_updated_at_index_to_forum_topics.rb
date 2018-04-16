class AddUpdatedAtIndexToForumTopics < ActiveRecord::Migration[4.2]
  def up
    execute "set statement_timeout = 0"
    add_index :forum_topics, :updated_at
  end

  def down
    execute "set statement_timeout = 0"
    remove_index :forum_topics, :updated_at
  end
end
