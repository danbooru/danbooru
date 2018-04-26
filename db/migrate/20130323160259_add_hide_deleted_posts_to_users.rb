class AddHideDeletedPostsToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :hide_deleted_posts, :boolean, :null => false, :default => false
  end
end
