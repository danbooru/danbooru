class AddParentIdToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :parent_id, :integer
  end
end
