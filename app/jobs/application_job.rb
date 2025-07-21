# frozen_string_literal: true

# The base class for all background jobs on Danbooru.
#
# @see https://guides.rubyonrails.org/active_job_basics.html
# @see https://github.com/bensheldon/good_job
class ApplicationJob < ActiveJob::Base
  class JobTimeoutError < StandardError; end

  queue_as :default

  # Jobs with lower numbers are processed first. Lower number = higher priority.
  # ProcessUploadJob:           priority -20
  # ProcessUploadMediaAssetJob: priority -10
  # Other jobs:                 priority 0
  # PopulateSavedSearchJob:     priority 10
  queue_with_priority 0

  # Called for background jobs enqueued with `perform_later`. Not called for foreground jobs performed with `perform_now`.
  around_enqueue do |_job, block|
    ApplicationMetrics[:rails_jobs_enqueue_duration_seconds][**job_labels, job_type: "background"].increment_duration(&block)
    ApplicationMetrics[:rails_jobs_enqueued_total][**job_labels, job_type: "background"].increment
  end

  around_perform do |job, block|
    ApplicationMetrics[:rails_jobs_attempts_total][job_labels].increment
    ApplicationMetrics[:rails_jobs_retries_total][job_labels].increment if executions > 1

    if background_job?
      # We have to use wall time here rather than a monotonic clock because the job could come from a different machine.
      # This could be inaccurate due to clocks moving forward or backwards, or machines having unsynchronized clocks.
      queue_duration = Time.zone.now - enqueued_at
      ApplicationMetrics[:rails_jobs_queue_duration_seconds][job_labels].increment(queue_duration)
    end

    ApplicationMetrics[:rails_jobs_duration_seconds][job_labels].increment_duration(&block)
    ApplicationMetrics[:rails_jobs_worked_total][job_labels].increment # This only counts successful jobs that didn't raise an error
  end

  around_perform do |_job, block|
    CurrentUser.scoped(User.system) do
      ApplicationRecord.without_timeout do
        Timeout.timeout(job_timeout, JobTimeoutError) do
          block.call
        end
      end
    end
  end

  # Record the exception then re-raise it to let the job fail. For background jobs, GoodJob.on_thread_error will also be
  # called, which will log the error. For foreground jobs, the error will just be raised up to the caller.
  rescue_from Exception do |exception|
    ApplicationMetrics[:rails_jobs_exceptions_total][**job_labels, exception: exception.class.name].increment
    raise
  end

  discard_on ActiveJob::DeserializationError do |_job, error|
    DanbooruLogger.log(error)
  end

  # @return [Duration] The amount of time to let a job run before it is canceled. May be overridden by subclasses.
  def job_timeout
    24.hours
  end

  # @return [Hash] Metric labels for the job.
  def job_labels
    { job: self.class.name, queue: queue_name, priority: priority, job_type: background_job? ? "background" : "foreground" }
  end

  # @return [Boolean] True if the job is a background job (enqueued with `perform_later`); false if the job is a
  #   foreground job (enqueued with `perform_now`).
  def background_job?
    enqueued_at.present?
  end

  # @return [Array<Class>] A list of all available job types. Used by the /jobs search form.
  def self.job_classes
    # Load subclasses so we return all subclasses in development mode (where classes are lazily loaded).
    Dir.glob("#{__dir__}/*.rb").each { |file| require file } unless Rails.application.config.eager_load

    subclasses.sort_by(&:name)
  end
end
