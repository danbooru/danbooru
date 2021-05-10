class CreateIpGeolocations < ActiveRecord::Migration[6.1]
  def change
    create_table :ip_geolocations do |t|
      t.timestamps null: false, index: true

      t.inet :ip_addr, null: false, index: { unique: true }
      t.inet :network, index: true
      t.integer :asn, index: true
      t.boolean :is_proxy, null: false, index: true
      t.float :latitude, index: true
      t.float :longitude, index: true
      t.string :organization, index: true
      t.string :time_zone, index: true
      t.string :continent, index: true
      t.string :country, index: true
      t.string :region, index: true
      t.string :city, index: true
      t.string :carrier, index: true
    end
  end
end
