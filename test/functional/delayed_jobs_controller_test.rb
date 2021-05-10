require 'test_helper'

class DelayedJobsControllerTest < ActionDispatch::IntegrationTest
  context "The delayed jobs controller" do
    setup do
      @user = create(:admin_user)
      @job = create(:delayed_job)
    end

    context "index action" do
      should "render" do
        get delayed_jobs_path
        assert_response :success
      end
    end

    context "cancel action" do
      should "work" do
        put_auth cancel_delayed_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "retry action" do
      should "work" do
        put_auth retry_delayed_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "run action" do
      should "work" do
        put_auth run_delayed_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "destroy action" do
      should "work" do
        delete_auth delayed_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end
  end
end
