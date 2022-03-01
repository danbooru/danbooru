class AddPageURLToUploadMediaAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :upload_media_assets, :page_url, :string, null: true
  end
end
