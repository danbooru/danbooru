require "test_helper"

class ReadOnlyModeServiceTest < ActiveSupport::TestCase
  teardown do
    ReadOnlyMode.unpause_jobs!
    Danbooru.config.unstub(:read_only_mode?)
  end

  should "pause and unpause all application jobs" do
    ReadOnlyMode.pause_jobs!
    assert_equal(true, GoodJob::Setting.paused?(label: ReadOnlyMode::LABEL))

    ReadOnlyMode.unpause_jobs!
    assert_equal(false, GoodJob::Setting.paused?(label: ReadOnlyMode::LABEL))
  end

  should "not unpause a manually paused queue" do
    GoodJob::Setting.pause(queue: "default")

    ReadOnlyMode.unpause_jobs!

    assert_equal(true, GoodJob::Setting.paused?(queue: "default"))
  ensure
    GoodJob::Setting.unpause(queue: "default")
  end

  should "label application jobs" do
    assert_equal([ReadOnlyMode::LABEL], PruneJobsJob.new.good_job_labels)
  end

  should "exclude paused labeled jobs from dequeue" do
    ReadOnlyMode.pause_jobs!
    job = GoodJob::Job.create!(
      id: SecureRandom.uuid,
      queue_name: "default",
      priority: 0,
      serialized_params: {},
      scheduled_at: Time.zone.now,
      job_class: "PruneJobsJob",
      labels: [ReadOnlyMode::LABEL],
    )

    assert_not_includes(GoodJob::Job.exclude_paused, job)
  ensure
    ReadOnlyMode.unpause_jobs!
  end

  should "not enqueue maintenance jobs" do
    Danbooru.config.stubs(:read_only_mode?).returns(true)

    assert_no_enqueued_jobs do
      DanbooruMaintenance.queue(PruneJobsJob)
    end
  end
end
