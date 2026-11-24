# frozen_string_literal: true

# An IP intelligence provider for https://ipapi.is.
#
# Unlike IPRegistry, it doesn't return the carrier's name, only an `is_mobile` flag.
#
# @see https://ipapi.is/developers.html
class IpIntelligence::IpApi < IpIntelligence
  # The key goes in a POST body instead of a GET param to keep it out of URLs and logs.
  memoize def response
    http_response = http.post("https://api.ipapi.is", json: { q: ip_addr.to_s, key: api_key })
    json = http_response.to_s.parse_json if http_response.status == 200
    json.is_a?(Hash) ? json.with_indifferent_access : {}
  end

  def attributes
    {
      network: response.dig(:asn, :route),
      asn: response.dig(:asn, :asn),
      latitude: response.dig(:location, :latitude),
      longitude: response.dig(:location, :longitude),
      organization: response.dig(:asn, :org).presence || response.dig(:company, :name),
      time_zone: response.dig(:location, :timezone),
      continent: response.dig(:location, :continent),
      country: response.dig(:location, :country_code),
      region: response.dig(:location, :state),
      city: response.dig(:location, :city),
      carrier: nil,
    }
  end

  # The most specific type wins. Most VPNs are only flagged as datacenter IPs, and residential proxies mostly aren't
  # detected. A company type of "hosting" without the datacenter flag is ignored, since it's not about the IP itself.
  def ip_type
    if response[:is_tor] == true
      "tor"
    elsif response[:is_vpn] == true
      "vpn"
    elsif response[:is_proxy] == true
      "proxy"
    elsif response[:is_datacenter] == true
      "hosting"
    elsif response[:is_mobile] == true
      "mobile"
    else
      response.dig(:company, :type).presence_in(%w[isp business education government])
    end
  end

  # Leave out fields that change on every request (local time, timing), the abuse contact, the time zone (already a
  # column), and fields that are the same for every IP in the country (calling code, currency, EU membership).
  def saved_response
    slice_fields(response, [
      %w[ip rir is_bogon is_mobile is_satellite is_anycast is_crawler is_datacenter is_tor is_proxy is_vpn is_abuser],
      { "vpn" => %w[is_vpn service url type exit_node_region last_seen_str] },
      { "egress_service" => %w[type provider] },
      { "datacenter" => %w[datacenter domain network region service country state city] },
      { "abuser" => %w[source_count total_sources] },
      { "company" => %w[name abuser_score domain type network] },
      { "asn" => %w[asn abuser_score route descr country org domain type] },
      { "location" => %w[continent country country_code state city latitude longitude zip accuracy] },
    ])
  end
end
