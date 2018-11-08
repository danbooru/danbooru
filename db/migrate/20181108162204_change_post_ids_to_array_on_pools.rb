class ChangePostIdsToArrayOnPools < ActiveRecord::Migration[5.2]
  def up
    Pool.without_timeout do
      change_column_default :pools, :post_ids, nil
      change_column :pools, :post_ids, "integer[]", using: "string_to_array(post_ids, ' ')::integer[]"
      change_column_default :pools, :post_ids, "{}"
    end
  end

  def down
    Pool.without_timeout do
      change_column_default :pools, :post_ids, nil
      change_column :pools, :post_ids, :text, using: "array_to_string(post_ids, ' ')"
      change_column_default :pools, :post_ids, ""
    end
  end
end
