class AddIpAddrToDmails < ActiveRecord::Migration[4.2]
  def change
    execute "set statement_timeout = 0"
    add_column :dmails, :creator_ip_addr, :inet, :null => false, :default => "127.0.0.1"
    add_index :dmails, :creator_ip_addr
  end
end
