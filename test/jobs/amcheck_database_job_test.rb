require 'test_helper'

class AmcheckDatabaseJobTest < ActiveJob::TestCase
  context "AmcheckDatabaseJob" do
    should "work" do
      AmcheckDatabaseJob.perform_now
    end
  end
end
