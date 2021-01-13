require 'test_helper'

class IpGeolocationsControllerTest < ActionDispatch::IntegrationTest
  context "The ip geolocations controller" do
    context "index action" do
      should "render for a moderator" do
        get_auth ip_geolocations_path, create(:moderator_user)
        assert_response :success
      end

      should "fail for a normal user" do
        get_auth ip_geolocations_path, create(:user)
        assert_response 403
      end
    end
  end
end
