class SetMediaAssetToNullableOnUploadMediaAssets < ActiveRecord::Migration[7.0]
  def change
    change_column_null :upload_media_assets, :media_asset_id, true
  end
end
