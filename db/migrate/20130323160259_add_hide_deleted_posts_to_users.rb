class AddHideDeletedPostsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hide_deleted_posts, :boolean, :null => false, :default => false
  end
end
