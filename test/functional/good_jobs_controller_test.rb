require "test_helper"

class GoodJobsControllerTest < ActionDispatch::IntegrationTest
  context "The good job controller" do
    context "index action" do
      should "allow access for an admin" do
        get_auth good_job.jobs_path, create(:admin_user)

        assert_response :success
        assert_nil(CurrentUser.user)
      end

      should "deny access for a non-admin" do
        user = create(:user)
        Dmail.create_automated(to: user, title: "Test", body: "Test") # Test that the dmail notice renders

        get_auth good_job.jobs_path, user

        assert_response 403
        assert_nil(CurrentUser.user)
      end

      should "clear the current user before the next request" do
        get_auth good_job.jobs_path, create(:admin_user)

        assert_response :success
        assert_nil(CurrentUser.user)

        get profile_path

        assert_response 404
        assert_nil(CurrentUser.user)
      end
    end
  end
end
