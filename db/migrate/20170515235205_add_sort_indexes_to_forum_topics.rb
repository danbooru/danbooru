class AddSortIndexesToForumTopics < ActiveRecord::Migration[4.2]
  def change
    add_index :forum_topics, [:is_sticky, :updated_at]
  end
end
