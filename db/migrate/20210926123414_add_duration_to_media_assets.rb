class AddDurationToMediaAssets < ActiveRecord::Migration[6.1]
  def change
    add_column :media_assets, :duration, :float, null: true, default: nil, if_not_exists: true
    add_index :media_assets, :duration, where: "duration IS NOT NULL"
  end
end
