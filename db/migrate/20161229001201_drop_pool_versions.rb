class DropPoolVersions < ActiveRecord::Migration
  def up
  	drop_table :pool_versions
  end

  def down
  	raise NotImplementedError
  end
end
