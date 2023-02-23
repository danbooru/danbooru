class AddPixelHashToMediaAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :media_assets, :pixel_hash, :uuid, null: true
  end
end
