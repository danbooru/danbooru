class RenameIpAddrOnComments < ActiveRecord::Migration[5.2]
  def change
    rename_column :comments, :ip_addr, :creator_ip_addr
  end
end
