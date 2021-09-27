require 'test_helper'

class DanbooruMaintenanceTest < ActiveSupport::TestCase
  context "hourly maintenance" do
    should "work" do
      assert_nothing_raised do
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
  end
end
