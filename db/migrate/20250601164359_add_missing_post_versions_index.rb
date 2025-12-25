class AddMissingPostVersionsIndex < ActiveRecord::Migration[7.1]
  def up
    add_index :post_versions, [:updater_id, :id], name: "index_post_versons_on_updater_id_and_id"
  end

  def down
    remove_index :post_versions, name: "index_post_versons_on_updater_id_and_id"
  end
end
