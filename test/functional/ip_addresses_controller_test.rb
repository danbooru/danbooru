require 'test_helper'

class IpAddressesControllerTest < ActionDispatch::IntegrationTest
  context "The IP addresses controller" do
    setup do
      @mod = create(:mod_user, last_ip_addr: "1.2.3.4")
      @user = create(:user, last_ip_addr: "5.6.7.8")

      CurrentUser.scoped(@user, "5.6.7.9") do
        @note = create(:note)
        @artist = create(:artist)
      end
    end

    context "index action" do
      should "list all IP addresses" do
        get_auth ip_addresses_path, @mod
        assert_response :success
      end

      should "allow searching by subnet" do
        get_auth ip_addresses_path(search: { ip_addr: "5.0.0.0/8" }), @mod, as: :json

        assert_response :success
        assert(response.parsed_body.present?)
      end

      should "allow grouping by user" do
        get_auth ip_addresses_path(search: { ip_addr: @user.last_ip_addr, group_by: "user" }), @mod
        assert_response :success
      end

      should "allow grouping by IP" do
        get_auth ip_addresses_path(search: { user_id: @user.id, group_by: "ip_addr" }), @mod
        assert_response :success
      end

      should "not allow non-moderators to view IP addresses" do
        get_auth ip_addresses_path, @user
        assert_response 403
      end
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
    end
  end
end
