require "test_helper"

class JobsControllerTest < ActionDispatch::IntegrationTest
  context "The jobs controller" do
    setup do
      @user = create(:admin_user)
      @job = create(:good_job, scheduled_at: 1.minute.ago)
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

      context "searching by params" do
        setup do
          @victim = create(:user)
          mail_job = MailDeliveryJob.new("UserMailer", "password_reset", "deliver_now", args: [@victim])
          @user_job = create(:good_job, job: mail_job, serialized_params: mail_job.serialize)
          @search = { serialized_params: { arguments: [{ args: [{ _aj_globalid: @victim.to_global_id.to_s }] }] }}
        end

        should "not allow non-admins to search by params" do
          get jobs_path(search: @search), as: :json

          assert_response :success
          assert_equal([], response.parsed_body)
        end

        should "allow admins to search by params" do
          get_auth jobs_path(search: @search), @user, as: :json

          assert_response :success
          assert_equal([@user_job.id], response.parsed_body.pluck("id"))
        end
      end

      context "a job with an error" do
        setup do
          @failed_job = create(:good_job, error: "Net::SMTPFatalError: 550 <victim@example.com> rejected")
        end

        should "not show the error to non-admins" do
          get jobs_path, as: :json

          assert_response :success
          assert_not_includes(response.body, "victim@example.com")
        end

        should "show the error to admins" do
          get_auth jobs_path, @user, as: :json

          assert_response :success
          assert_includes(response.body, "victim@example.com")
        end

        should "not allow non-admins to search by the error" do
          get jobs_path(search: { error_ilike: "*victim@*" }), as: :json

          assert_response :success
          assert_equal([], response.parsed_body)
        end

        should "allow admins to search by the error" do
          get_auth jobs_path(search: { error_ilike: "*victim@*" }), @user, as: :json

          assert_response :success
          assert_equal([@failed_job.id], response.parsed_body.pluck("id"))
        end
      end
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
        @job.active_job.class.stubs(:queue_adapter).returns(GoodJob::Adapter.new)
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
