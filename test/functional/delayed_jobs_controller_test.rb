require 'test_helper'

class DelayedJobsControllerTest < ActionController::TestCase
  context "The delayed jobs controller" do
    context "index action" do
      should "render" do
        get :index
        assert_response :success
      end
    end
  end
end
