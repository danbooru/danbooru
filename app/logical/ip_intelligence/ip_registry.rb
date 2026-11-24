# frozen_string_literal: true

# An IP intelligence provider for https://ipregistry.co.
#
# @see https://ipregistry.co/docs
class IpIntelligence::IpRegistry < IpIntelligence
  memoize def response
    # https://ipregistry.co/docs/authentication
    http_response = Danbooru::Http.headers(Authorization: "ApiKey #{api_key}").get("https://api.ipregistry.co/#{ip_addr}")
    json = http_response.to_s.parse_json if http_response.status == 200
    json.is_a?(Hash) ? json.with_indifferent_access : {}
  end

  def attributes
    {
      provider: "ipregistry",
      ip_type: ip_type,
      operator: (response.dig(:carrier, :name) if ip_type == "mobile"),
      network: response.dig(:connection, :route),
      asn: response.dig(:connection, :asn),
      latitude: response.dig(:location, :latitude),
      longitude: response.dig(:location, :longitude),
      organization: response.dig(:connection, :organization),
      time_zone: response.dig(:time_zone, :id),
      continent: response.dig(:location, :continent, :code),
      country: response.dig(:location, :country, :code),
      region: response.dig(:location, :region, :name),
      city: response.dig(:location, :city),
      carrier: response.dig(:carrier, :name),
    }
  end

  # The most specific type wins. IPs with a carrier are mobile IPs. The abuser, attacker, threat, and bogon flags are
  # ignored, since they don't say what kind of IP it is.
  def ip_type
    security = response[:security].is_a?(Hash) ? response[:security].select { |_, value| value == true }.keys : []
    connection_type = response.dig(:connection, :type)

    if security.intersect?(%w[is_tor is_tor_exit])
      "tor"
    elsif security.include?("is_relay")
      "relay"
    elsif security.include?("is_vpn")
      "vpn"
    elsif security.include?("is_residential_proxy")
      "residential_proxy"
    elsif security.include?("is_proxy")
      "proxy"
    elsif connection_type == "hosting" || security.include?("is_cloud_provider")
      "hosting"
    elsif response.dig(:carrier, :name).present?
      "mobile"
    else
      connection_type.presence_in(%w[isp business education government])
    end
  end

  # Leave out country-wide fields (currency, language, country details) and the time zone, which is already a column.
  def saved_response
    slice_fields(response, [
      %w[ip type hostname],
      { "carrier" => %w[name mcc mnc] },
      { "company" => %w[domain name type] },
      { "connection" => %w[asn domain is_anycast organization route type] },
      { "location" => [{ "continent" => %w[code name] }, { "country" => %w[code name] }, { "region" => %w[code name] }, %w[city postal latitude longitude]] },
      { "security" => %w[is_abuser is_anonymous is_attacker is_bogon is_cloud_provider is_proxy is_relay is_residential_proxy is_threat is_tor is_tor_exit is_vpn] },
    ])
  end
end
