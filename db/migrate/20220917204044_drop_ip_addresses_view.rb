class DropIpAddressesView < ActiveRecord::Migration[7.0]
  def change
    drop_view :ip_addresses, revert_to_version: 1
  end
end
