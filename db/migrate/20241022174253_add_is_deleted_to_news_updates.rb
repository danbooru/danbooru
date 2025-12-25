class AddIsDeletedToNewsUpdates < ActiveRecord::Migration[7.1]
  def change
    add_column :news_updates, :is_deleted, :boolean, null: false, default: false
  end
end
