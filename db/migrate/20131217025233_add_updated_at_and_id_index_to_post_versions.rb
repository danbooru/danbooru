class AddUpdatedAtAndIdIndexToPostVersions < ActiveRecord::Migration[4.2]
  def self.up
    execute "set statement_timeout = 0"
    remove_index :post_versions, :updated_at
    add_index :post_versions, [:updated_at, :id]
  end

  def self.down
    execute "set statement_timeout = 0"
    remove_index :post_versions, [:updated_at, :id]
    add_index :post_versions, :updated_at
  end
end
