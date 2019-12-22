class AddMinLevelToForumTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :forum_topics, :min_level, :integer, :default => 0, :null => false
  end
end
