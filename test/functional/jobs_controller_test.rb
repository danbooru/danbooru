require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  context "The jobs controller" do
    setup do
      @user = create(:admin_user)
      @job = create(:good_job)
    end

    context "index action" do
      should "render" do
        get jobs_path
        assert_response :success
      end

      should respond_to_search(status: "running").with { [] }
      should respond_to_search(status: "queued").with { [@job] }
      should respond_to_search(status: "finished").with { [] }
      should respond_to_search(status: "discarded").with { [] }
    end

    context "cancel action" do
      should "work" do
        GoodJob::Job.any_instance.stubs(:status).returns(:queued)
        put_auth cancel_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "retry action" do
      should "work" do
        @job.discard_job("Canceled")
        @job.head_execution.active_job.class.stubs(:queue_adapter).returns(GoodJob::Adapter.new)
        put_auth retry_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "run action" do
      should "work" do
        GoodJob::Job.any_instance.stubs(:status).returns(:queued)
        put_auth run_job_path(@job), @user, xhr: true
        assert_response :success
      end
    end

    context "destroy action" do
      should "work" do
        delete_auth job_path(@job), @user, xhr: true
        assert_response :success
      end
    end
  end
end
