class RemoveDefaultIpAddrFromDmails < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:dmails, :creator_ip_addr, nil)
  end

  def down
    change_column_default(:dmails, :creator_ip_addr, "127.0.0.1")
  end
end
