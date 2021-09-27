require 'test_helper'

class PruneRateLimitsJobTest < ActiveJob::TestCase
  context "PruneRateLimitsJob" do
    should "prune all stale rate limits" do
      travel_to(2.hours.ago) { create(:rate_limit) }

      assert_equal(1, RateLimit.count)
      PruneRateLimitsJob.perform_now
      assert_equal(0, RateLimit.count)
    end
  end
end
