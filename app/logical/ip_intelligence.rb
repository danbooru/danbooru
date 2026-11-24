# frozen_string_literal: true

# Looks up an IP's geolocation, network, and type (ISP, mobile, hosting, VPN, etc) from an IP intelligence provider.
#
# Each provider is a subclass. Use `IpIntelligence.for` to get the configured provider, which is set as a URL like
# "ipregistry://<key>" or "ipapi.is://<key>".
#
# @example
#   IpIntelligence.for("1.1.1.1").attributes
#   IpIntelligence.for("1.1.1.1", provider: "ipapi.is://<key>").ip_type
class IpIntelligence
  extend Memoist

  PROVIDERS = {
    "null" => Null,
    "ipregistry" => IpRegistry,
    "ipapi.is" => IpApi,
  }.freeze

  attr_reader :ip_addr, :api_key, :cache_duration

  # @param ip_addr [String, Danbooru::IpAddress] The IP address to look up.
  # @param provider [String, nil] The provider's URL. Defaults to the configured provider.
  # @return [IpIntelligence] The provider, or IpIntelligence::Null if the URL isn't a valid provider URL with a key.
  def self.for(ip_addr, provider: Danbooru.config.ip_intelligence_provider)
    klass, api_key = find_provider(provider)
    klass.new(ip_addr, api_key: api_key)
  end

  # @param provider [String, nil] The provider's URL, e.g. "ipregistry://<key>".
  # @return [Array(Class, String)] The provider's class and API key, or [IpIntelligence::Null, nil].
  def self.find_provider(provider)
    uri = URI.parse(provider.to_s)
    klass = PROVIDERS[uri.scheme]
    key = uri.host

    (klass && key.present?) ? [klass, key] : [Null, nil]
  rescue URI::InvalidURIError
    [Null, nil]
  end

  # @param ip_addr [String, Danbooru::IpAddress] The IP address to look up.
  # @param api_key [String, nil] The provider's API key.
  # @param cache_duration [ActiveSupport::Duration] How long to cache successful responses.
  def initialize(ip_addr, api_key: nil, cache_duration: 3.days)
    @ip_addr = Danbooru::IpAddress.new(ip_addr)
    @api_key = api_key
    @cache_duration = cache_duration
  end

  # Hide the API key. Inspecting doesn't fetch the response, so it doesn't use up lookup credits.
  def inspect
    ivars = (instance_variables - [:@api_key]).map { |name| "#{name}=#{instance_variable_get(name).inspect}" }
    "#<#{self.class.name} #{ivars.join(" ")}>"
  end

  # @return [Hash] The response, normalized to the `ip_geolocations` columns (except `ip_addr` and `is_proxy`).
  def attributes
    {}
  end

  # @return [Hash] The provider's raw API response, or an empty hash if the lookup failed or the IP is local.
  def response
    {}
  end

  # @return [Danbooru::Http] An HTTP client that caches only successful responses, under a key without the API key.
  def http
    Danbooru::Http.cache(cache_duration, key: "#{self.class.name.underscore}:#{ip_addr}", if: ->(response) { response.status == 200 })
  end

  # @return [Hash] An allowlist of the response's fields to save in `ip_geolocations`.
  def saved_response
    {}
  end

  # @return [String, nil] What kind of IP it is, e.g. "isp", "mobile", or "vpn", or nil if unknown.
  def ip_type
    nil
  end

  # @return [Boolean] True for hosting, proxy, VPN, relay, and Tor IPs. False if the type is unknown.
  def proxy?
    ip_type.in?(%w[hosting proxy residential_proxy vpn relay tor])
  end

  private

  # Keep only the given fields, so new fields from the provider aren't saved without us deciding to. Fields are given
  # like strong params: `["ip", { "location" => ["city", "country"] }]`.
  #
  # @param hash [Hash] The response, or part of it.
  # @param fields [Array<String, Array, Hash>] The fields to keep. Nested arrays are flattened.
  # @return [Hash] The response with only the given fields.
  def slice_fields(hash, fields)
    fields.flatten.flat_map { |field| field.is_a?(Hash) ? field.to_a : [[field, nil]] }.filter_map do |key, subfields|
      next unless hash.key?(key)

      value = hash[key]
      value = slice_fields(value, subfields) if subfields && value.is_a?(Hash)
      [key, value]
    end.to_h.with_indifferent_access
  end
end
