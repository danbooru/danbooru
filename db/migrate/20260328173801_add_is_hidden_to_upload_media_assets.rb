# frozen_string_literal: true

class AddIsHiddenToUploadMediaAssets < ActiveRecord::Migration[7.1]
  def change
    add_column :upload_media_assets, :is_hidden, :boolean, default: false, null: false
    add_index :upload_media_assets, :is_hidden, where: "is_hidden = TRUE"
  end
end
