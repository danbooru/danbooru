class AddIsDeletedToCommentVotes < ActiveRecord::Migration[6.1]
  def change
    add_column :comment_votes, :is_deleted, :boolean, default: false, null: :false
    change_column_null :comment_votes, :is_deleted, false

    add_index :comment_votes, :is_deleted, where: "is_deleted = TRUE"

    remove_index :comment_votes, [:user_id, :comment_id], unique: true
    add_index :comment_votes, [:user_id, :comment_id], unique: true, where: "is_deleted = FALSE"
  end
end
