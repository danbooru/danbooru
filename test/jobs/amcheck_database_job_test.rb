require "test_helper"

class AmcheckDatabaseJobTest < ActiveJob::TestCase
  context "AmcheckDatabaseJob" do
    should "work" do
      create(:superadmin_user)
      assert_nothing_raised { AmcheckDatabaseJob.perform_now }
    end
  end
end
