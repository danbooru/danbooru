class AddParentIdToUploads < ActiveRecord::Migration[4.2]
  def change
    add_column :uploads, :parent_id, :integer
  end
end
