# frozen_string_literal: true

# An IpGeolocation contains metadata associated with an IP address, primarily geolocation data.

class IpGeolocation < ApplicationRecord
  attribute :ip_addr, :ip_address
  attribute :network, :ip_address

  def self.visible(user)
    user.is_moderator? ? all : none
  end

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)
    q.apply_default_order(params)
  end

  def self.create_or_update!(ip)
    ip_address = Danbooru::IpAddress.new(ip)
    return nil if ip_address.ip_info.blank?

    ip_geolocation = IpGeolocation.create_with(**ip_address.ip_info).create_or_find_by!(ip_addr: ip_address)
    ip_geolocation.update!(**ip_address.ip_info)
    ip_geolocation
  end
end
