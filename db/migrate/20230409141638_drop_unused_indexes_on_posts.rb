class DropUnusedIndexesOnPosts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    remove_index :posts, :image_width, algorithm: :concurrently, if_exists: true
    remove_index :posts, :image_height, algorithm: :concurrently, if_exists: true
    remove_index :posts, :file_size, algorithm: :concurrently, if_exists: true
    remove_index :posts, column: "((image_width * image_height)::numeric / 1000000.0)", name: "index_posts_on_mpixels", algorithm: :concurrently, if_exists: true
  end
end
