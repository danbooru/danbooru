require "test_helper"

class IpGeolocationsControllerTest < ActionDispatch::IntegrationTest
  context "The ip geolocations controller" do
    context "index action" do
      should "render for a moderator" do
        get_auth ip_geolocations_path, create(:moderator_user)
        assert_response :success
      end

      should "show IP types by name" do
        create(:ip_geolocation, ip_type: "residential_proxy")
        create(:ip_geolocation, ip_type: "isp")

        get_auth ip_geolocations_path, create(:moderator_user)

        assert_response :success
        assert_select "td", text: "Residential proxy"
        assert_select "td", text: "ISP"
        assert_select "select[name='search[ip_type]'] option[value='residential_proxy']", text: "Residential proxy"
      end

      should "fail for a normal user" do
        get_auth ip_geolocations_path, create(:user)
        assert_response 403
      end

      should "search by provider, IP type, operator, and last checked date" do
        mod = create(:moderator_user)
        vpn = create(:ip_geolocation, provider: "ipapi", ip_type: "vpn", operator: "NordVPN", is_proxy: true, checked_at: 1.day.ago)
        mobile = create(:ip_geolocation, provider: "ipregistry", ip_type: "mobile", checked_at: 30.days.ago)

        get_auth ip_geolocations_path(format: :json, search: { provider: "ipapi" }), mod
        assert_equal([vpn.id], response.parsed_body.pluck("id"))

        get_auth ip_geolocations_path(format: :json, search: { ip_type: "vpn" }), mod
        assert_equal([vpn.id], response.parsed_body.pluck("id"))

        get_auth ip_geolocations_path(format: :json, search: { ip_type: "mobile" }), mod
        assert_equal([mobile.id], response.parsed_body.pluck("id"))

        get_auth ip_geolocations_path(format: :json, search: { operator: "NordVPN" }), mod
        assert_equal([vpn.id], response.parsed_body.pluck("id"))

        get_auth ip_geolocations_path(format: :json, search: { checked_at: "<#{7.days.ago.iso8601}" }), mod
        assert_equal([mobile.id], response.parsed_body.pluck("id"))
      end
    end
  end
end
