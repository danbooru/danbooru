require "test_helper"

class IpAddressesControllerTest < ActionDispatch::IntegrationTest
  context "The IP addresses controller" do
    setup do
      @mod = create(:mod_user, last_ip_addr: "1.2.3.4")
      @user = create(:user, last_ip_addr: "5.6.7.8")
    end

    context "show action" do
      should "be visible to mods" do
        get_auth ip_address_path("1.2.3.4"), @mod
        assert_response :success
      end

      should "not be visible to members" do
        get_auth ip_address_path("1.2.3.4"), @user
        assert_response 403
      end

      should "return 404 for an invalid IP address" do
        get_auth ip_address_path("abc"), @mod
        assert_response 404
      end

      should "return 403 for an invalid IP address to non-mods" do
        get_auth ip_address_path("abc"), @user
        assert_response 403

        get ip_address_path("abc")
        assert_response 403
      end

      should "show the saved IP information without looking up the IP again" do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipregistry://ipregistry-key")
        create(:ip_geolocation, ip_addr: "1.2.3.4", city: "Springfield", ip_type: "vpn", operator: "NordVPN", checked_at: 1.day.ago, response: { "hostname" => "host.example.com" })
        Danbooru::Http.any_instance.expects(:get).never

        get_auth ip_address_path("1.2.3.4"), @mod

        assert_response :success
        assert_select "td", text: /Springfield/
        assert_select "td", text: /VPN[[:space:]]+\(NordVPN\)/
        assert_select "pre", text: /host\.example\.com/
      end

      should "return the saved IP information in the API" do
        Danbooru.config.stubs(:ip_intelligence_provider).returns("ipregistry://ipregistry-key")
        create(:ip_geolocation, ip_addr: "1.2.3.4", city: "Springfield", checked_at: 1.day.ago)
        Danbooru::Http.any_instance.expects(:get).never

        get_auth ip_address_path("1.2.3.4", format: :json), @mod

        assert_response :success
        assert_equal("1.2.3.4", response.parsed_body["ip_addr"])
        assert_equal("Springfield", response.parsed_body["city"])
      end

      should "work for a Tor address" do
        get_auth ip_address_path("2405:8100:8000::1"), @mod
        assert_response :success
      end
    end
  end
end
