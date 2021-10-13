class AddUniqueUserIdAndPostIdIndexToPostDisapprovals < ActiveRecord::Migration[6.1]
  def change
    add_index :post_disapprovals, [:user_id, :post_id], unique: true
  end
end
