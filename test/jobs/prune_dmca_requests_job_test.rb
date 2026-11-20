require "test_helper"

class PruneDmcaRequestsJobTest < ActiveJob::TestCase
  context "PruneDmcaRequestsJob" do
    should "purge the personal info of old DMCA requests" do
      dmca_request = create(:dmca_request, status: :handled, created_at: DmcaRequest::PERSONAL_INFO_RETENTION.ago - 1.day)

      PruneDmcaRequestsJob.perform_now

      assert_nil(dmca_request.reload.email)
    end
  end
end
