class AddIsDeletedToUploads < ActiveRecord::Migration[7.0]
  def change
    add_column :uploads, :is_deleted, :bool, null: false, default: false
    add_index :uploads, :is_deleted, where: "is_deleted = true"
  end
end
