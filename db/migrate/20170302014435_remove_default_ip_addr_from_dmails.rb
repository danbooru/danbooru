class RemoveDefaultIpAddrFromDmails < ActiveRecord::Migration
  def up
    change_column_default(:dmails, :creator_ip_addr, nil)
  end

  def down
    change_column_default(:dmails, :creator_ip_addr, "127.0.0.1")
  end
end
