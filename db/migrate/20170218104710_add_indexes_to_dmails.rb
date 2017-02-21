class AddIndexesToDmails < ActiveRecord::Migration
  def change
    execute "set statement_timeout = 0"
    add_index :dmails, :is_read
    add_index :dmails, :is_deleted
  end
end
