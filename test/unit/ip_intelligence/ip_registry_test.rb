require "test_helper"

class IpIntelligence::IpRegistryTest < ActiveSupport::TestCase
  def mock_ipregistry(ip_addr, status: 200, **response)
    mock_request("https://api.ipregistry.co/#{ip_addr}", status: status, body: response.to_json)
  end

  def ip_type(**response)
    mock_ipregistry("45.83.91.1", **response)
    IpIntelligence.for("45.83.91.1", provider: "ipregistry://ipregistry-key").ip_type
  end

  context "IpIntelligence::IpRegistry:" do
    context "for a mobile IP" do
      setup do
        mock_ipregistry(
          "2a01:e35:2f22:e3d0::1",
          connection: { asn: 12_322, organization: "Free SAS", route: "2a01:e30::/28", type: "isp" },
          location: {
            continent: { code: "EU" }, country: { code: "FR" }, region: { code: "FR-IDF", name: "Ile-de-France" },
            city: "Argenteuil", latitude: 48.95, longitude: 2.25,
          },
          time_zone: { id: "Europe/Paris" },
          carrier: { name: "Free" },
          security: { is_vpn: false, is_proxy: false, is_cloud_provider: false },
        )
        @ip = IpIntelligence.for("2a01:e35:2f22:e3d0::1", provider: "ipregistry://ipregistry-key")
      end

      should "return the IP's information" do
        assert_equal("2a01:e30::/28", @ip.attributes[:network])
        assert_equal(12_322, @ip.attributes[:asn])
        assert_equal(48.95, @ip.attributes[:latitude])
        assert_equal(2.25, @ip.attributes[:longitude])
        assert_equal("Free SAS", @ip.attributes[:organization])
        assert_equal("Europe/Paris", @ip.attributes[:time_zone])
        assert_equal("EU", @ip.attributes[:continent])
        assert_equal("FR", @ip.attributes[:country])
        assert_equal("Ile-de-France", @ip.attributes[:region])
        assert_equal("Argenteuil", @ip.attributes[:city])
        assert_equal("Free", @ip.attributes[:carrier])
      end

      should "be a mobile IP, because it has a carrier" do
        assert_equal("mobile", @ip.ip_type)
        assert_equal("Free", @ip.attributes[:operator])
      end
    end

    should "use the carrier as the operator only for mobile IPs" do
      mock_ipregistry("45.83.91.1", connection: { type: "hosting" }, carrier: { name: "Free" })

      assert_nil(IpIntelligence.for("45.83.91.1", provider: "ipregistry://ipregistry-key").attributes[:operator])
    end

    should "return the most specific IP type when several flags are set" do
      assert_equal("tor", ip_type(connection: { type: "hosting" }, security: { is_tor: true, is_vpn: true }))
      assert_equal("tor", ip_type(connection: { type: "hosting" }, security: { is_tor_exit: true }))
      assert_equal("relay", ip_type(connection: { type: "hosting" }, security: { is_relay: true, is_anonymous: true }))
      assert_equal("vpn", ip_type(connection: { type: "hosting" }, security: { is_vpn: true, is_proxy: true }))
      assert_equal("residential_proxy", ip_type(connection: { type: "isp" }, security: { is_residential_proxy: true, is_proxy: true }))
      assert_equal("proxy", ip_type(connection: { type: "hosting" }, security: { is_proxy: true }))
      assert_equal("hosting", ip_type(connection: { type: "isp" }, carrier: { name: "Free" }, security: { is_cloud_provider: true }))
      assert_equal("hosting", ip_type(connection: { type: "hosting" }, carrier: { name: "Free" }))
      assert_equal("mobile", ip_type(connection: { type: "isp" }, carrier: { name: "Free" }))
    end

    should "return the connection type for IPs with no flags" do
      assert_equal("isp", ip_type(connection: { type: "isp" }, carrier: { name: nil }, security: { is_vpn: false }))
      assert_equal("business", ip_type(connection: { type: "business" }))
      assert_equal("education", ip_type(connection: { type: "education" }))
      assert_equal("government", ip_type(connection: { type: "government" }))
    end

    should "return no IP type for unknown connection types or flags that don't say what the IP is" do
      assert_nil(ip_type(connection: { type: "inactive" }))
      assert_nil(ip_type(security: { is_abuser: true, is_attacker: true, is_threat: true, is_bogon: true }))
      assert_nil(ip_type(security: { is_vpn: "true" }))
      assert_nil(ip_type(security: "vpn"))
      assert_nil(ip_type)
    end

    should "save only information about the IP itself" do
      mock_ipregistry(
        "157.230.244.215",
        ip: "157.230.244.215",
        connection: { asn: 14_061, type: "hosting" },
        currency: { code: "USD", name: "US Dollar", format: { decimal_separator: "." }},
        location: {
          continent: { code: "NA", name: "North America" },
          country: { code: "US", name: "United States", capital: "Washington", population: 340_000_000, flag: { emoji: "🇺🇸" }, languages: [{ code: "en" }] },
          region: { code: "US-NJ", name: "New Jersey" },
          city: "Clifton", postal: "07014", latitude: 40.8, longitude: -74.1, in_eu: false,
          language: { code: "en", name: "English" },
        },
        time_zone: { id: "America/New_York", name: "Eastern Standard Time", current_time: "2026-11-21T12:00:00-05:00", offset: -18_000 },
        security: { is_vpn: false, is_cloud_provider: true, is_new_flag: true },
        new_field: "value",
      )
      ip = IpIntelligence.for("157.230.244.215", provider: "ipregistry://ipregistry-key")
      response = ip.saved_response

      assert_equal(%w[connection ip location security], response.keys.sort)
      assert_equal(%w[city continent country latitude longitude postal region], response[:location].keys.sort)
      assert_equal({ "code" => "US", "name" => "United States" }, response[:location][:country])
      assert_equal("America/New_York", ip.attributes[:time_zone])
      assert_equal({ "code" => "US-NJ", "name" => "New Jersey" }, response[:location][:region])
      assert_equal({ "is_vpn" => false, "is_cloud_provider" => true }, response[:security])
    end

    should "return no information when the request fails" do
      mock_ipregistry("1.1.1.1", status: 429, code: "TOO_MANY_REQUESTS")
      ip = IpIntelligence.for("1.1.1.1", provider: "ipregistry://ipregistry-key")

      assert_equal({}, ip.response)
      assert_nil(ip.ip_type)
    end
  end
end
