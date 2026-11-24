# frozen_string_literal: true

class AddProviderColumnsToIpGeolocations < ActiveRecord::Migration[8.1]
  def change
    change_table :ip_geolocations, bulk: true do |t|
      # The IP intelligence provider the data came from: 0 = IPRegistry. Existing rows all came from IPRegistry.
      t.integer :provider, null: false, default: 0

      # What kind of IP it is, e.g. ISP, mobile, hosting, VPN, or Tor (see IpGeolocation). Null if unknown.
      t.integer :ip_type

      # Who runs the IP on the network, if the provider knows it: the VPN service (e.g. NordVPN) or the mobile carrier
      # (e.g. T-Mobile). `organization` is who owns the network.
      t.string :operator

      # When the provider was last queried for this IP. Null for rows from before this column was added.
      t.datetime :checked_at

      # The provider's raw API response.
      t.jsonb :response
    end
  end
end
