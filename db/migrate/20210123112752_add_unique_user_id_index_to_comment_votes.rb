class AddUniqueUserIdIndexToCommentVotes < ActiveRecord::Migration[6.1]
  def change
    add_index :comment_votes, [:user_id, :comment_id], unique: true
  end
end
