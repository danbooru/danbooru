require 'test_helper'

class ModActionsControllerTest < ActionController::TestCase
  context "The mod actions controller" do
    context "index action" do
      should "work" do
        get :index
        assert_response :success
      end
    end
  end
end
