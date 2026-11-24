# frozen_string_literal: true

# An IpGeolocation contains metadata associated with an IP address, primarily geolocation data. It's looked up from an
# IP intelligence provider (see IpIntelligence) and saved here, so this table also serves as the cache for lookups.
class IpGeolocation < ApplicationRecord
  attribute :ip_addr, :ip_address
  attribute :network, :ip_address

  enum :provider, { ipregistry: 0, ipapi: 100 }, validate: true

  # What kind of IP it is. When an IP is more than one type, the provider picks the most specific one, e.g. a VPN in a
  # datacenter is a VPN. The types from `hosting` on count as proxies. Null if the provider doesn't say.
  enum :ip_type, {
    isp: 0, mobile: 100, business: 200, education: 300, government: 400,
    hosting: 1000, proxy: 1100, residential_proxy: 1200, vpn: 1300, relay: 1400, tor: 1500,
  }, prefix: true, validate: { allow_nil: true }

  IP_TYPE_NAMES = {
    "isp" => "ISP", "mobile" => "Mobile", "business" => "Business", "education" => "Education", "government" => "Government",
    "hosting" => "Hosting", "proxy" => "Proxy", "residential_proxy" => "Residential proxy", "vpn" => "VPN", "relay" => "Relay",
    "tor" => "Tor",
  }.freeze

  def self.search(params, current_user)
    q = search_attributes(params, current_user: current_user)
    q.apply_default_order(params)
  end

  # Return the saved information for an IP, or look it up from the IP intelligence provider and save it if it hasn't
  # been checked within `max_age`. If looking it up fails, the old record is returned.
  #
  # Errors while looking up or saving the IP are logged and treated as a failed lookup, so that a bad response from the
  # provider doesn't break logins and signups.
  #
  # @param ip [String, Danbooru::IpAddress] The IP address.
  # @param max_age [ActiveSupport::Duration] How long saved information is used before the IP is looked up again.
  # @return [IpGeolocation, nil] The IP's information, or nil if the IP is local or couldn't be looked up.
  def self.find_or_lookup!(ip, max_age: 7.days)
    ip_address = Danbooru::IpAddress.new(ip)
    return nil if ip_address.is_local?

    ip_geolocation = find_by(ip_addr: ip_address)
    return ip_geolocation if ip_geolocation&.checked_at&.after?(max_age.ago)

    begin
      lookup!(ip_address) || ip_geolocation
    rescue StandardError => e
      DanbooruLogger.log(e, ip_addr: ip_address.to_s)
      ip_geolocation
    end
  end

  # Look up an IP from the IP intelligence provider and save the result, creating or updating the IP's record.
  #
  # The record is saved with a single upsert, so if two requests look up the same IP at the same time, both save their
  # result without error, and the last one wins. The upsert skips validations, but the only validations are on
  # `provider` and `ip_type`, which come from the provider class, not from users. It runs in a savepoint, so that if it
  # fails inside a transaction, the transaction can carry on.
  #
  # @param ip [String, Danbooru::IpAddress] The IP address.
  # @return [IpGeolocation, nil] The IP's information, or nil if the IP is local, a Tor IP, or couldn't be looked up.
  def self.lookup!(ip)
    ip_address = Danbooru::IpAddress.new(ip)
    return nil if ip_address.is_local? || ip_address.is_tor?

    ip_intelligence = IpIntelligence.for(ip_address)
    return nil if ip_intelligence.response.blank?

    attributes = { ip_addr: ip_address.to_s, **ip_intelligence.attributes, is_proxy: ip_intelligence.proxy?, response: ip_intelligence.saved_response, checked_at: Time.zone.now }
    transaction(requires_new: true) do
      upsert(attributes, unique_by: :ip_addr) # rubocop:disable Rails/SkipsModelValidations
    end
    find_by!(ip_addr: ip_address)
  end

  # @return [String, nil] The IP type's name as shown to users, e.g. "Residential proxy" or "VPN".
  def ip_type_name
    IP_TYPE_NAMES[ip_type]
  end

  # @return [Hash] The IP's information, in the same format as before it was saved here. Returned by the IP address API.
  def ip_info
    slice(:ip_addr, :network, :asn, :is_proxy, :latitude, :longitude, :organization, :time_zone, :continent, :country, :region, :city, :carrier).merge(ip_addr: ip_addr.to_s, network: network&.to_s).with_indifferent_access
  end
end
