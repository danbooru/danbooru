class ChangeIsPublicDefaultOnFavoriteGroups < ActiveRecord::Migration[6.0]
  def change
    change_column_default :favorite_groups, :is_public, from: false, to: true
    add_index :favorite_groups, :is_public
  end
end
