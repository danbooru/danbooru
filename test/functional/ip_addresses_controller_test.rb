require 'test_helper'

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

      should "work for a Tor address" do
        get_auth ip_address_path("2405:8100:8000::1"), @mod
        assert_response :success
      end
    end
  end
end
