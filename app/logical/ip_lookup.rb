# frozen_string_literal: true

# An API client for https://ipregistry.co. Looks up IP address information,
# including the geolocation and whether the IP is a proxy.
#
# @see https://ipregistry.co/docs
class IpLookup
  extend Memoist

  attr_reader :ip_addr, :api_key, :cache_duration

  def self.enabled?
    Danbooru.config.ip_registry_api_key.present?
  end

  def initialize(ip_addr, api_key: Danbooru.config.ip_registry_api_key, cache_duration: 3.days)
    @ip_addr = Danbooru::IpAddress.new(ip_addr)
    @api_key = api_key
    @cache_duration = cache_duration
  end

  def ip_info
    return {} if ip_addr.is_local?
    return {} if ip_addr.is_tor?
    return {} if response.blank?

    {
      ip_addr: ip_addr.to_s,
      network: response.dig(:connection, :route),
      asn: response.dig(:connection, :asn),
      is_proxy: is_proxy?,
      latitude: response.dig(:location, :latitude),
      longitude: response.dig(:location, :longitude),
      organization: response.dig(:connection, :organization),
      time_zone: response.dig(:time_zone, :id),
      continent: response.dig(:location, :continent, :code),
      country: response.dig(:location, :country, :code),
      region: response.dig(:location, :region, :code),
      city: response.dig(:location, :city),
      carrier: response.dig(:carrier, :name),
    }.with_indifferent_access
  end

  def response
    return {} if api_key.blank?
    response = Danbooru::Http.cache(cache_duration).get("https://api.ipregistry.co/#{ip_addr.to_s}?key=#{api_key}")
    return {} if response.status != 200
    json = response.parse.deep_symbolize_keys.with_indifferent_access
    json
  end

  def is_proxy?
    return false if ip_addr.is_local?
    return true if ip_addr.is_tor?
    return true if response.dig(:connection, :type) == "hosting"
    response[:security].present? && response[:security].values.any?
  end

  memoize :response, :is_proxy?
end
