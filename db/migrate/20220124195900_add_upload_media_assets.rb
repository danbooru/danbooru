class AddUploadMediaAssets < ActiveRecord::Migration[7.0]
  def change
    create_table :upload_media_assets do |t|
      t.timestamps null: false
      t.belongs_to :upload, null: false
      t.belongs_to :media_asset, null: false
    end

    add_foreign_key :upload_media_assets, :uploads, deferrable: :deferred
    add_foreign_key :upload_media_assets, :media_assets, deferrable: :deferred
  end
end
