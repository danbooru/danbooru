class DropGoldFeatures < ActiveRecord::Migration[7.0]
  def change
    update_view :user_actions, version: 2, revert_to_version: 1
    drop_table :upgrade_codes
    drop_table :user_upgrades
    remove_column :favorite_groups, :is_public
  end
end
