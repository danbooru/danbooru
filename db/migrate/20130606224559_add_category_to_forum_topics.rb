class AddCategoryToForumTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :forum_topics, :category_id, :integer, :default => 0, :null => false
  end
end
