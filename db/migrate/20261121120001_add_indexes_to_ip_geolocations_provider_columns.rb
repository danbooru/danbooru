# frozen_string_literal: true

class AddIndexesToIpGeolocationsProviderColumns < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :ip_geolocations, :ip_type, algorithm: :concurrently, if_not_exists: true
    add_index :ip_geolocations, :operator, where: "operator IS NOT NULL", algorithm: :concurrently, if_not_exists: true
    add_index :ip_geolocations, :checked_at, algorithm: :concurrently, if_not_exists: true
  end
end
