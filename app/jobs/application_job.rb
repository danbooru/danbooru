# frozen_string_literal: true

# The base class for all background jobs on Danbooru.
#
# @see https://guides.rubyonrails.org/active_job_basics.html
# @see https://github.com/collectiveidea/delayed_job
class ApplicationJob < ActiveJob::Base
  queue_as :default
  queue_with_priority 0

  around_perform do |_job, block|
    CurrentUser.scoped(User.system, "127.0.0.1") do
      ApplicationRecord.without_timeout do
        block.call
      end
    end
  end

  discard_on ActiveJob::DeserializationError do |_job, error|
    DanbooruLogger.log(error)
  end
end
