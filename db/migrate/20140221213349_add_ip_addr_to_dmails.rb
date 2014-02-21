class AddIpAddrToDmails < ActiveRecord::Migration
  def change
    add_column :dmails, :creator_ip_addr, :inet, :null => false, :default => "127.0.0.1"
  end
end
