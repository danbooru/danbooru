require "test_helper"

class PruneApiKeysJobTest < ActiveJob::TestCase
  context "PruneApiKeysJob" do
    should "delete expired API keys" do
      expired_key = create(:api_key, expires: true, expires_on: Date.tomorrow)

      travel_to(2.years.from_now) do
        active_key = create(:api_key, expires: true, expires_on: Date.tomorrow)

        PruneApiKeysJob.perform_now

        assert_not(ApiKey.exists?(expired_key.id))
        assert(ApiKey.exists?(active_key.id))
      end
    end
  end
end
