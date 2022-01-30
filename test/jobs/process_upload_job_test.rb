require 'test_helper'

class ProcessUploadJobTest < ActiveJob::TestCase
  context "ProcessUploadJob" do
    should "process a pending upload" do
      upload = create(:upload, status: "pending", source: "https://cdn.donmai.us/original/d3/4e/d34e4cf0a437a5d65f8e82b7bcd02606.jpg")
      ProcessUploadJob.perform_now(upload)

      assert_equal("completed", upload.status)
      assert_equal("d34e4cf0a437a5d65f8e82b7bcd02606", upload.media_assets.first.md5)
    end
  end
end
