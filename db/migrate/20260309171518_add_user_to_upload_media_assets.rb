class AddUserToUploadMediaAssets < ActiveRecord::Migration[8.0]
  def change
    add_column :upload_media_assets, :user_id, :integer, null: true
  end
end
