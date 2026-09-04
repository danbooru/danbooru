require "test_helper"

class DanbooruMaintenanceTest < ActiveSupport::TestCase
  context "hourly maintenance" do
    should "work" do
      assert_nothing_raised do
        DanbooruMaintenance.hourly
        perform_enqueued_jobs
      end
    end

    should "log errors" do
      assert_raise(RuntimeError) do
        PrunePostsJob.stubs(:perform_later).raises(RuntimeError)
        DanbooruLogger.expects(:log)

        DanbooruMaintenance.hourly
        perform_enqueued_jobs
      end
    end
  end

  context "daily maintenance" do
    should "work" do
      assert_nothing_raised do
        DanbooruMaintenance.daily
        perform_enqueued_jobs
      end
    end
  end

  context "weekly maintenance" do
    should "work" do
      assert_nothing_raised do
        DanbooruMaintenance.weekly
        perform_enqueued_jobs
      end
    end
  end

  context "monthly maintenance" do
    should "work" do
      assert_nothing_raised do
        DanbooruMaintenance.monthly
        perform_enqueued_jobs
      end
    end

    # `every(1.month, ...)` doesn't anchor to the first of the month; it fires
    # `period` after the job's last run, so a cron container restart resets
    # that and can trigger the job on any day.
    # @see https://github.com/danbooru/danbooru/issues/5435
    context "the monthly cron job" do
      setup do
        @event = Clockwork.manager.instance_variable_get(:@events).find { |event| event.to_s == "monthly" }
        @event.instance_variable_set(:@last, nil) # simulate the cron container restarting
      end

      should "not run on a day other than the first of the month" do
        assert_equal(false, @event.run_now?(Time.utc(2026, 1, 15)))
      end

      should "run on the first of the month" do
        assert_equal(true, @event.run_now?(Time.utc(2026, 1, 1)))
      end
    end
  end
end
