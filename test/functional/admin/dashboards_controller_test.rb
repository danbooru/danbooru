require 'test_helper'

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  context "The admin dashboard controller" do
    setup do
      @admin = create(:admin_user)
    end
    
    context "show action" do
      should "render" do
        get_auth admin_dashboard_path, @admin
        assert_response :success
      end
    end
  end
end
