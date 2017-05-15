class AddSortIndexesToForumTopics < ActiveRecord::Migration
  def change
  	add_index :forum_topics, [:is_sticky, :updated_at]
  end
end
