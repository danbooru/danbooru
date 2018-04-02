class AddIsPublicToFavoriteGroups < ActiveRecord::Migration[4.2]
  def change
    FavoriteGroup.without_timeout do
      add_column :favorite_groups, :is_public, :boolean, default: false, null: false
    end
  end
end
