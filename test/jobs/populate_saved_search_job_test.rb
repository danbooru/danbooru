require "test_helper"

class PopulateSavedSearchJobTest < ActiveJob::TestCase
  context "PopulateSavedSearchJob" do
    setup do
      PopulateSavedSearchJob.stubs(:queue_adapter).returns(GoodJob::Adapter.new(execution_mode: :external))
    end

    should "not queue the same search more than once at a time" do
      PopulateSavedSearchJob.perform_later("touhou")
      PopulateSavedSearchJob.perform_later("touhou")
      PopulateSavedSearchJob.perform_later("bkub")

      assert_equal(%w[bkub touhou], GoodJob::Job.where(job_class: "PopulateSavedSearchJob").map { it.serialized_params["arguments"].first }.sort)
    end
  end
end
