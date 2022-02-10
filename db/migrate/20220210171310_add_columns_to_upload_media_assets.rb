class AddColumnsToUploadMediaAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :media_asset_count, :integer, null: false, default: 0
    add_column :upload_media_assets, :status, :integer, null: false, default: 0
    add_column :upload_media_assets, :source_url, :string, null: false, default: ""
    add_column :upload_media_assets, :error, :string, null: true

    add_index :uploads, :media_asset_count
    add_index :upload_media_assets, :status
    add_index :upload_media_assets, :error, where: "error IS NOT NULL"
  end
end
