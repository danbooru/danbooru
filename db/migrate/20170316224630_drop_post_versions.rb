class DropPostVersions < ActiveRecord::Migration
  def change
  	execute "set statement_timeout = 0"
  	drop_table :post_versions
  end
end
