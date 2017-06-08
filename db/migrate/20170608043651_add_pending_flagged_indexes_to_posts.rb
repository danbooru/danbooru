class AddPendingFlaggedIndexesToPosts < ActiveRecord::Migration
  def change
    Post.without_timeout do
      add_index :posts, :is_pending, where: "is_pending = true"
      add_index :posts, :is_flagged, where: "is_flagged = true"
    end
  end
end
