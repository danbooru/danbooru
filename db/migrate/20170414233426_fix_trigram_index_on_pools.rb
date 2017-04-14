class FixTrigramIndexOnPools < ActiveRecord::Migration
  def up
    execute "drop index index_pools_on_name_trgm"
    execute "create index index_pools_on_name_trgm on pools using gin (lower(name) gin_trgm_ops)"
  end

  def down
    execute "drop index index_pools_on_name_trgm"
  end
 end
