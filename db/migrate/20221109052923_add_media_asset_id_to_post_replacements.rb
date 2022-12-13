class AddMediaAssetIdToPostReplacements < ActiveRecord::Migration[7.0]
  def change
    add_reference :post_replacements, :media_asset, type: :integer, null: true, index: true, foreign_key: { to_table: :media_assets }
    add_reference :post_replacements, :old_media_asset, type: :integer, null: true, index: true, foreign_key: { to_table: :media_assets }

    add_index :post_replacements, :md5
    add_index :post_replacements, :old_md5
  end
end
