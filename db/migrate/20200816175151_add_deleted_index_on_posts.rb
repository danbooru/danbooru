class AddDeletedIndexOnPosts < ActiveRecord::Migration[6.0]
  def change
    add_index :posts, :is_deleted, where: "is_deleted = true"
  end
end
