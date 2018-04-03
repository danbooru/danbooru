require 'test_helper'

class DelayedJobsControllerTest < ActionDispatch::IntegrationTest
  context "The delayed jobs controller" do
    context "index action" do
      should "render" do
        get delayed_jobs_path
        assert_response :success
      end
    end
  end
end
