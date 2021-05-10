# An IpGeolocation contains metadata associated with an IP address, primarily geolocation data.

class IpGeolocation < ApplicationRecord
  attribute :ip_addr, :ip_address
  attribute :network, :ip_address

  has_many :user_sessions, foreign_key: :ip_addr, primary_key: :ip_addr

  def self.visible(user)
    if user.is_moderator?
      all
    else
      none
    end
  end

  def self.search(params)
    q = search_attributes(params, :id, :created_at, :updated_at, :ip_addr, :network, :asn, :is_proxy, :latitude, :longitude, :organization, :time_zone, :continent, :country, :region, :city, :carrier)
    q = q.apply_default_order(params)
    q
  end

  def self.create_or_update!(ip)
    ip_address = Danbooru::IpAddress.new(ip)
    return nil if ip_address.ip_info.blank?

    ip_geolocation = IpGeolocation.create_with(**ip_address.ip_info).create_or_find_by!(ip_addr: ip_address)
    ip_geolocation.update!(**ip_address.ip_info)
    ip_geolocation
  end
end
