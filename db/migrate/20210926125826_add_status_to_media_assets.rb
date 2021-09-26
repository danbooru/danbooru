class AddStatusToMediaAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :media_assets, :status, :integer, null: false, default: 200, if_not_exists: true
    add_index :media_assets, :status, where: "status != 200"
  end
end
