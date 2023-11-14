require 'test_helper'

class PruneUploadsJobTest < ActiveJob::TestCase
  context "PruneUploadsJob" do
    should "prune expired uploads and media assets" do
      upload = create(:upload, created_at: 6.hours.ago, status: "processing")
      media_asset = create(:media_asset, created_at: 6.hours.ago, status: "processing")
      upload_media_asset = create(:upload_media_asset, created_at: 6.hours.ago, media_asset: media_asset, upload: upload, status: "processing")

      PruneUploadsJob.perform_now

      assert_equal("error", upload.reload.status)
      assert_equal("failed", upload_media_asset.reload.status)
      assert_equal("failed", media_asset.reload.status)
    end
  end
end
