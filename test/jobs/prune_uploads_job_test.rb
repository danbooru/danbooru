require 'test_helper'

class PruneUploadsJobTest < ActiveJob::TestCase
  context "PruneUploadsJob" do
    should "prune all old uploads" do
      @uploader = create(:user)

      as(@uploader) do
        @completed_upload = travel_to(2.hours.ago) { create(:upload, uploader: @uploader, status: "completed") }
        @stale_upload = travel_to(2.days.ago) { create(:upload, uploader: @uploader, status: "preprocessed") }
        @failed_upload = travel_to(4.days.ago) { create(:upload, uploader: @uploader, status: "error") }
      end

      assert_equal(3, Upload.count)
      PruneUploadsJob.perform_now
      assert_equal(0, Upload.count)
    end
  end
end
