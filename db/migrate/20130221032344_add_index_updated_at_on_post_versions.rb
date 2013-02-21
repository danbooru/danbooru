class AddIndexUpdatedAtOnPostVersions < ActiveRecord::Migration
  def up
    execute "set statement_timeout = 0"
    add_index :post_versions, :updated_at
  end

  def down
    execute "set statement_timeout = 0"
    remove_index :post_versions, :updated_at
  end
end
