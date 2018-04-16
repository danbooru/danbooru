class AddTrigramIndexToPools < ActiveRecord::Migration[4.2]
  def up
    execute "create extension pg_trgm"
    execute "create index index_pools_on_name_trgm on pools using gin (name gin_trgm_ops)"
  end

  def down
    execute "drop index index_pools_on_name_trgm"
    execute "drop extension pg_trgm"
  end
end
