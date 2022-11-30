# frozen_string_literal: true

# The base class for all background jobs on Danbooru.
#
# @see https://guides.rubyonrails.org/active_job_basics.html
# @see https://github.com/bensheldon/good_job
class ApplicationJob < ActiveJob::Base
  # Preload subclasses so `job_classes` returns all subclasses in development mode.
  Dir["#{__dir__}/*.rb"].each { |file| require file }

  class JobTimeoutError < StandardError; end

  queue_as :default

  # Jobs with higher priority are processed first. Higher number = higher priority.
  queue_with_priority 0

  around_perform do |_job, block|
    CurrentUser.scoped(User.system) do
      ApplicationRecord.without_timeout do
        Timeout.timeout(24.hours, JobTimeoutError) do
          block.call
        end
      end
    end
  end

  discard_on ActiveJob::DeserializationError do |_job, error|
    DanbooruLogger.log(error)
  end

  # A list of all available job types. Used by the /jobs search form.
  def self.job_classes
    subclasses.sort_by(&:name)
  end
end
