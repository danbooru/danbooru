class AddIsDeletedToNewsUpdates < ActiveRecord::Migration[7.0]
  def change
    add_column :news_updates, :is_deleted, :boolean, default: false, null: false
  end
end
