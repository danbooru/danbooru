class ApplicationJob < ActiveJob::Base
  queue_as :default
  queue_with_priority 0

  discard_on ActiveJob::DeserializationError do |job, error|
    DanbooruLogger.log(error)
  end
end
