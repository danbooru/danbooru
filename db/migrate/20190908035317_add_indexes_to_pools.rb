class AddIndexesToPools < ActiveRecord::Migration[6.0]
  def change
    add_index :pools, :category
    add_index :pools, :is_deleted
    add_index :pools, :post_ids, using: :gin
  end
end
