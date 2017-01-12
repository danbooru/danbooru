class ChangeIpAddrToInetOnPostAppeals < ActiveRecord::Migration
  def up
    execute "set statement_timeout = 0"
    change_column_null :post_appeals, :creator_ip_addr, true
    execute "ALTER TABLE post_appeals ALTER COLUMN creator_ip_addr TYPE inet USING NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover the lost data"
  end
end
