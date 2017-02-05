require 'test_helper'

class Admin::DashboardsControllerTest < ActionController::TestCase
  context "The admin dashboard controller" do
    context "show action" do
      should "render" do
        get :show
        assert_response :success
      end
    end
  end
end
