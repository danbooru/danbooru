class DropPostCountFromPools < ActiveRecord::Migration[5.2]
  def up
    remove_column :pools, :post_count
  end

  def down
    add_column :pools, :post_count, :integer, default: 0, null: false
    Pool.update_all("post_count = cardinality(post_ids)")
  end
end
