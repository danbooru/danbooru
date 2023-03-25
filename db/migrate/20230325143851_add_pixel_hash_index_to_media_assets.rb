class AddPixelHashIndexToMediaAssets < ActiveRecord::Migration[7.0]
  include MigrationHelpers
  disable_ddl_transaction!

  def change
    add_not_null_constraint :media_assets, :file_key
    add_not_null_constraint :media_assets, :pixel_hash
    add_index :media_assets, :pixel_hash, algorithm: :concurrently, if_not_exists: true
  end
end
