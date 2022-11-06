class AddIsDeletedToUsers < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    add_column :users, :is_deleted, :boolean, null: false, default: false
    add_index :users, :is_deleted, where: "is_deleted = TRUE", algorithm: :concurrently
  end
end
