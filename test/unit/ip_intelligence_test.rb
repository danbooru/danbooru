require "test_helper"

class IpIntelligenceTest < ActiveSupport::TestCase
  context "IpIntelligence:" do
    setup do
      Danbooru.config.stubs(:ip_intelligence_provider).returns(nil)
    end

    context "the for method" do
      should "return the provider named by the URL's scheme, with the API key from the URL" do
        ipregistry = IpIntelligence.for("1.1.1.1", provider: "ipregistry://ipregistry-key")
        ipapi = IpIntelligence.for("1.1.1.1", provider: "ipapi.is://Ipapi_Key-123")

        assert_instance_of(IpIntelligence::IpRegistry, ipregistry)
        assert_equal("ipregistry-key", ipregistry.api_key)
        assert_instance_of(IpIntelligence::IpApi, ipapi)
        assert_equal("Ipapi_Key-123", ipapi.api_key)
      end

      should "use the configured provider by default" do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipapi.is://ipapi-key")

        assert_instance_of(IpIntelligence::IpApi, IpIntelligence.for("1.1.1.1"))
      end

      should "return the null provider when no provider is configured" do
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1"))
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: ""))
      end

      should "return the null provider when the URL has no API key" do
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "ipregistry://"))
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "ipregistry:key"))
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "ipregistry"))
      end

      should "return the null provider for an unknown provider or an invalid URL" do
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "bogus://key"))
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "https://key"))
        assert_instance_of(IpIntelligence::Null, IpIntelligence.for("1.1.1.1", provider: "ipapi.is://a b"))
      end
    end

    context "the inspect method" do
      should "hide the API key, and show the response once it's been fetched" do
        mock_request("https://api.ipapi.is", method: :post, json: { q: "1.1.1.1", key: "secret-key" }, body: { ip: "1.1.1.1", is_vpn: true }.to_json)
        ip = IpIntelligence.for("1.1.1.1", provider: "ipapi.is://secret-key")

        assert_no_match(/secret-key/, ip.inspect)
        assert_match(/1\.1\.1\.1/, ip.inspect)
        assert_no_match(/is_vpn/, ip.inspect)

        ip.response
        assert_no_match(/secret-key/, ip.inspect)
        assert_match(/"is_vpn" => true/, ip.inspect)
      end
    end

    context "the null provider" do
      should "return no information" do
        ip = IpIntelligence.for("1.1.1.1")

        assert_equal({}, ip.attributes)
        assert_equal({}, ip.response)
        assert_equal({}, ip.saved_response)
        assert_nil(ip.ip_type)
        assert_equal(false, ip.proxy?)
      end
    end
  end
end
