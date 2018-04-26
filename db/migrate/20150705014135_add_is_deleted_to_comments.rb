class AddIsDeletedToComments < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :comments, :is_deleted, :boolean, :null => false, :default => false
  end
end
