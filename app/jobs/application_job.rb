# The base class for all background jobs on Danbooru.
#
# @see https://guides.rubyonrails.org/active_job_basics.html
# @see https://github.com/collectiveidea/delayed_job
class ApplicationJob < ActiveJob::Base
  queue_as :default
  queue_with_priority 0

  discard_on ActiveJob::DeserializationError do |_job, error|
    DanbooruLogger.log(error)
  end
end
