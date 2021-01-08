# API client for https://ipregistry.co/

class IpLookup
  extend Memoist

  attr_reader :ip_addr, :api_key, :cache_duration

  def self.enabled?
    Danbooru.config.ip_registry_api_key.present?
  end

  def initialize(ip_addr, api_key: Danbooru.config.ip_registry_api_key, cache_duration: 3.days)
    @ip_addr = IPAddress.parse(ip_addr.to_s)
    @api_key = api_key
    @cache_duration = cache_duration
  end

  def ip_info
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

  def is_local?
    if ip_addr.ipv4?
      ip_addr.loopback? || ip_addr.link_local? || ip_addr.private?
    elsif ip_addr.ipv6?
      ip_addr.loopback? || ip_addr.link_local? || ip_addr.unique_local?
    end
  end

  def is_proxy?
    response[:security].present? && response[:security].values.any?
  end

  memoize :response, :is_proxy?
end
