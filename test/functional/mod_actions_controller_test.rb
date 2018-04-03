require 'test_helper'

class ModActionsControllerTest < ActionDispatch::IntegrationTest
  context "The mod actions controller" do
    context "index action" do
      should "work" do
        get mod_actions_path
        assert_response :success
      end
    end
  end
end
