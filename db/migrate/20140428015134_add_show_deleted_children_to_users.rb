class AddShowDeletedChildrenToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :show_deleted_children, :boolean, :null => false, :default => false
    add_column :posts, :has_active_children, :boolean
    change_column_default(:posts, :has_active_children, false)
  end
end
