class AddSubnetIndexToUserEvents < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  def change
    add_index :user_events, "network(set_masklen(ip_addr, CASE WHEN family(ip_addr) = 4 THEN 24 ELSE 64 END))", name: "index_user_events_on_ip_addr_subnet", algorithm: :concurrently
  end
end
