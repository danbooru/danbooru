class AddLowerNameIndexToPools < ActiveRecord::Migration
  def self.up
    execute "create index index_pools_on_lower_name on pools (lower(name))"
  end

  def self.down
    execute "drop index index_pools_on_lower_name"
  end
end
