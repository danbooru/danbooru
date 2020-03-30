require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  context "index action" do
    should "work" do
      get robots_path(format: :text)
      assert_response :success
    end
  end
end
