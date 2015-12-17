class AddLastIpAddrToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_ip_addr, :inet
    add_index :users, :last_ip_addr, where: "last_ip_addr is not null"
  end
end
