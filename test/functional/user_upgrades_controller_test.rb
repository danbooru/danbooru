require 'test_helper'

class UserUpgradesControllerTest < ActionDispatch::IntegrationTest
  context "The user upgrades controller" do
    context "new action" do
      should "render" do
        get new_user_upgrade_path
        assert_response :success
      end
    end

    context "show action" do
      should "render" do
        get_auth user_upgrade_path, create(:user)
        assert_response :success
      end
    end
  end
end
