class AddHideDeletedPostsToUsers < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_column :users, :hide_deleted_posts, :boolean, :null => false, :default => false
  end
end
