class ChangePostIdsToArrayOnFavoriteGroups < ActiveRecord::Migration[6.0]
  def up
    execute "set statement_timeout = 0"

    change_column_default :favorite_groups, :post_ids, nil
    change_column :favorite_groups, :post_ids, "integer[]", using: "string_to_array(post_ids, ' ')::integer[]"
    change_column_default :favorite_groups, :post_ids, "{}"
    add_index :favorite_groups, :post_ids, using: :gin

    remove_column :favorite_groups, :post_count
  end

  def down
    execute "set statement_timeout = 0"

    remove_index :favorite_groups, :post_ids
    change_column_default :favorite_groups, :post_ids, nil
    change_column :favorite_groups, :post_ids, :text, using: "array_to_string(post_ids, ' ')"
    change_column_default :favorite_groups, :post_ids, ""

    add_column :favorite_groups, :post_count, :integer, default: 0, null: false
  end
end
