GoodJob.active_record_parent_class = "ApplicationRecord"
GoodJob.retry_on_unhandled_error = false
GoodJob.preserve_job_records = true
Rails.application.config.good_job.smaller_number_is_higher_priority = true

# Called when a background job raises an unhandled exception. Only called for background jobs run with `perform_later`,
# not foreground jobs run with `perform_now`.
GoodJob.on_thread_error = ->(exception) do
  DanbooruLogger.log(exception)
end

# Start the metrics server on http://0.0.0.0:9090/metrics when bin/good_job is run.
if GoodJob::CLI.within_exe?
  Rails.application.config.after_initialize do
    RackMetricsServer.new.start
  end
end
