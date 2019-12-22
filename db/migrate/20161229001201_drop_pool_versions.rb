class DropPoolVersions < ActiveRecord::Migration[4.2]
  def up
    drop_table :pool_versions
  end

  def down
    raise NotImplementedError
  end
end
