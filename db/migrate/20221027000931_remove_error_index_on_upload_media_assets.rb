class RemoveErrorIndexOnUploadMediaAssets < ActiveRecord::Migration[7.0]
  def change
    remove_index :upload_media_assets, :error, where: "error IS NOT NULL"
  end
end
