class AddIsDeletedToPostVotes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :post_votes, :is_deleted, :boolean, default: false, null: :false
    add_index :post_votes, :is_deleted, where: "is_deleted = TRUE", algorithm: :concurrently
    add_index :post_votes, [:user_id, :post_id], unique: true, where: "is_deleted = FALSE", algorithm: :concurrently
  end
end
