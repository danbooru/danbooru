require 'test_helper'

class AmcheckDatabaseJobTest < ActiveJob::TestCase
  context "AmcheckDatabaseJob" do
    should "work" do
      create(:owner_user)
      AmcheckDatabaseJob.perform_now
    end
  end
end
