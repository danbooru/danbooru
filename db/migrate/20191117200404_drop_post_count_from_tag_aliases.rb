class DropPostCountFromTagAliases < ActiveRecord::Migration[6.0]
  def change
    remove_index :tag_aliases, :post_count
    remove_column :tag_aliases, :post_count, :integer, null: false, default: 0
  end
end
