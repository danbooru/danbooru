class AddNameToPoolVersions < ActiveRecord::Migration[4.2]
  def change
    execute("set statement_timeout = 0")
    add_column :pool_versions, :name, :string
    PoolVersion.find_each do |pool_version|
      pool_version.update_column(:name, pool_version.pool.name)
    end
  end
end
