class AddFileKeyToMediaAssets < ActiveRecord::Migration[7.0]
  def change
    add_column :media_assets, :file_key, :string, null: true
    add_column :media_assets, :is_public, :boolean, default: true, null: false

    add_index :media_assets, :file_key, unique: true
    add_index :media_assets, :is_public, where: "is_public = FALSE"
  end
end
