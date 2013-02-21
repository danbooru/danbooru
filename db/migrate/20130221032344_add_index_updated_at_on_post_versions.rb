class AddIndexUpdatedAtOnPostVersions < ActiveRecord::Migration
  def up
    add_index :post_versions, :updated_at
  end

  def down
    remove_index :post_versions, :updated_at
  end
end
