class AddNameToPoolVersions < ActiveRecord::Migration[4.2]
  def change
    execute("set statement_timeout = 0")
    add_column :pool_versions, :name, :string
  end
end
