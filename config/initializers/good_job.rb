GoodJob.active_record_parent_class = "ApplicationRecord"
GoodJob.retry_on_unhandled_error = false
GoodJob.preserve_job_records = true
GoodJob.on_thread_error = ->(exception) do
  DanbooruLogger.log(exception)
end
