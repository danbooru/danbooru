class AddTrigramIndexToUsers < ActiveRecord::Migration
  def change
  	execute "set statement_timeout = 0"
    execute "create index index_users_on_name_trgm on users using gin (lower(name) gin_trgm_ops)"
  end
end
