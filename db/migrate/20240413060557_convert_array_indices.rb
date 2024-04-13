class ConvertArrayIndices < ActiveRecord::Migration[7.1]
  def change
    remove_index :pool_versions, :post_ids
    remove_index :pool_versions, :added_post_ids
    remove_index :pool_versions, :removed_post_ids
    remove_index :post_versions, :added_tags
    remove_index :post_versions, :removed_tags

    add_index :pool_versions, :post_ids, using: :gin
    add_index :pool_versions, :added_post_ids, using: :gin
    add_index :pool_versions, :removed_post_ids, using: :gin
    add_index :post_versions, :added_tags, using: :gin
    add_index :post_versions, :removed_tags, using: :gin
  end
end
