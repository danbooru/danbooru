require "test_helper"

class TestJob < ApplicationJob
  def perform(record)
  end
end

class NoOpTestJob < ApplicationJob
  def perform
  end
end

class ApplicationJobTest < ActiveJob::TestCase
  context "An active job" do
    should "discard and log jobs with deserialization errors" do
      DanbooruLogger.expects(:log)

      assert_nothing_raised do
        perform_enqueued_jobs do
          tag = create(:tag, name: "tagme")
          tag.delete

          TestJob.perform_later(tag)
        end
      end
    end

    should "record how long background jobs waited to be worked" do
      ApplicationMetrics.reset_metrics

      freeze_time do
        NoOpTestJob.perform_later
        travel(3.seconds)
        perform_enqueued_jobs
      end

      prom = ApplicationMetrics[:rails_jobs_queue_latency_seconds].to_prom
      assert_includes(prom, %{rails_jobs_queue_latency_seconds_bucket{job="NoOpTestJob", le="2.5"} 0})
      assert_includes(prom, %{rails_jobs_queue_latency_seconds_bucket{job="NoOpTestJob", le="5"} 1})
      assert_includes(prom, %{rails_jobs_queue_latency_seconds_bucket{job="NoOpTestJob", le="3600"} 1})
      assert_includes(prom, %{rails_jobs_queue_latency_seconds_sum{job="NoOpTestJob"} 3})
      assert_includes(prom, %{rails_jobs_queue_latency_seconds_count{job="NoOpTestJob"} 1})
    ensure
      ApplicationMetrics.reset_metrics
    end

    should "not record a queue time for foreground jobs" do
      ApplicationMetrics.reset_metrics
      NoOpTestJob.perform_now

      assert_empty(ApplicationMetrics[:rails_jobs_queue_latency_seconds].values)
    ensure
      ApplicationMetrics.reset_metrics
    end
  end
end
