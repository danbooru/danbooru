class AddLastIpAddrToUsers < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :users, :last_ip_addr, :inet
    add_index :users, :last_ip_addr, where: "last_ip_addr is not null"
  end
end
