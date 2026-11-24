require "test_helper"

class IpIntelligence::IpApiTest < ActiveSupport::TestCase
  def mock_ipapi(ip_addr, status: 200, **response)
    mock_request("https://api.ipapi.is", method: :post, json: { q: ip_addr, key: "ipapi-key" }, status: status, body: response.to_json)
  end

  def flags(**flags)
    { is_bogon: false, is_mobile: false, is_datacenter: false, is_tor: false, is_proxy: false, is_vpn: false, is_abuser: false, **flags }
  end

  def ip_type(**response)
    mock_ipapi("45.83.91.1", **flags, **response)
    IpIntelligence.for("45.83.91.1", provider: "ipapi.is://ipapi-key").ip_type
  end

  context "IpIntelligence::IpApi:" do
    context "for a residential IP" do
      setup do
        mock_ipapi(
          "73.1.2.3",
          **flags,
          company: { name: "Comcast Cable Communications, LLC", type: "isp" },
          asn: { asn: 7922, route: "73.0.0.0/8", org: "Comcast Cable Communications, LLC" },
          location: {
            continent: "NA", country_code: "US", state: "Florida", city: "Miami",
            latitude: 25.77, longitude: -80.19, timezone: "America/New_York",
          },
        )
        @ip = IpIntelligence.for("73.1.2.3", provider: "ipapi.is://ipapi-key")
      end

      should "return the IP's information" do
        assert_equal("73.0.0.0/8", @ip.attributes[:network])
        assert_equal(7922, @ip.attributes[:asn])
        assert_equal(25.77, @ip.attributes[:latitude])
        assert_equal(-80.19, @ip.attributes[:longitude])
        assert_equal("Comcast Cable Communications, LLC", @ip.attributes[:organization])
        assert_equal("America/New_York", @ip.attributes[:time_zone])
        assert_equal("NA", @ip.attributes[:continent])
        assert_equal("US", @ip.attributes[:country])
        assert_equal("Florida", @ip.attributes[:region])
        assert_equal("Miami", @ip.attributes[:city])
        assert_nil(@ip.attributes[:carrier])
      end

      should "be an ISP IP" do
        assert_equal("isp", @ip.ip_type)
      end
    end

    should "fall back to the company name when the ASN has no organization" do
      mock_ipapi("13.215.175.208", **flags(is_datacenter: true), company: { name: "Amazon Data Services Singapore" }, asn: {})

      assert_equal("Amazon Data Services Singapore", IpIntelligence.for("13.215.175.208", provider: "ipapi.is://ipapi-key").attributes[:organization])
    end

    should "return the most specific IP type when several flags are set" do
      assert_equal("tor", ip_type(is_tor: true, is_vpn: true, is_datacenter: true))
      assert_equal("vpn", ip_type(is_vpn: true, is_proxy: true, is_datacenter: true))
      assert_equal("proxy", ip_type(is_proxy: true, is_datacenter: true))
      assert_equal("hosting", ip_type(is_datacenter: true, is_mobile: true))
      assert_equal("mobile", ip_type(is_mobile: true, company: { type: "isp" }))
    end

    should "return the company type for IPs with no flags" do
      assert_equal("isp", ip_type(company: { type: "isp" }))
      assert_equal("business", ip_type(company: { type: "business" }))
      assert_equal("education", ip_type(company: { type: "education" }))
      assert_equal("government", ip_type(company: { type: "government" }))
    end

    should "return no IP type for unknown company types or flags that don't say what the IP is" do
      assert_nil(ip_type(company: { type: "hosting" }))
      assert_nil(ip_type(company: { type: "banking" }))
      assert_nil(ip_type(is_abuser: true, is_bogon: true))
      assert_nil(ip_type(is_vpn: "true"))
      assert_nil(ip_type)
    end

    should "save only information about the IP itself" do
      mock_ipapi(
        "73.1.2.3",
        ip: "73.1.2.3",
        **flags,
        asn: { asn: 7922, route: "73.0.0.0/8" },
        location: {
          is_eu_member: false, calling_code: "1", currency_code: "USD", continent: "NA", country: "United States", country_code: "US",
          state: "Florida", city: "Miami", latitude: 25.77, longitude: -80.19, zip: "33101", timezone: "America/New_York",
          local_time: "2026-11-21T12:00:00-05:00", local_time_unix: 1_795_280_400, is_dst: false, utcoffset: "-05:00", accuracy: "MEDIUM",
        },
        abuse: { name: "Comcast", email: "abuse@comcast.net" },
        new_field: "value",
        elapsed_ms: 0.5,
      )
      ip = IpIntelligence.for("73.1.2.3", provider: "ipapi.is://ipapi-key")
      response = ip.saved_response

      assert_equal(%w[asn ip is_abuser is_bogon is_datacenter is_mobile is_proxy is_tor is_vpn location], response.keys.sort)
      assert_equal(7922, response.dig(:asn, :asn))
      assert_equal(false, response[:is_vpn])
      assert_equal(%w[accuracy city continent country country_code latitude longitude state zip], response[:location].keys.sort)
      assert_equal("America/New_York", ip.attributes[:time_zone])
    end

    should "return no information when the request fails" do
      mock_ipapi("1.1.1.1", status: 403, error: "Invalid API key")
      ip = IpIntelligence.for("1.1.1.1", provider: "ipapi.is://ipapi-key")

      assert_equal({}, ip.response)
      assert_nil(ip.ip_type)
    end
  end
end
