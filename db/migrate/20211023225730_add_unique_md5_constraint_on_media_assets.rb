class AddUniqueMd5ConstraintOnMediaAssets < ActiveRecord::Migration[6.1]
  def change
    add_index :media_assets, :md5, name: "index_media_assets_on_md5_and_status", unique: true, where: "status IN (100, 200)"
  end
end
