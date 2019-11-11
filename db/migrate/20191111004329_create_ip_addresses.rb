class CreateIpAddresses < ActiveRecord::Migration[6.0]
  def change
    create_view :ip_addresses
  end
end
