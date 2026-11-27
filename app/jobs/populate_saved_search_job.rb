# frozen_string_literal: true

# A job that updates a user's saved searches when they do a search for
# `search:all` or `search:<label>`.
class PopulateSavedSearchJob < ApplicationJob
  include GoodJob::ActiveJobExtensions::Concurrency

  queue_with_priority 10

  # Don't queue the same search again while it's waiting to run or running.
  good_job_concurrency_rule label: -> { "populate_saved_search:#{Digest::SHA256.hexdigest(arguments.first.to_s)}" }, apply_label: true, total_limit: 1

  def perform(query)
    SavedSearch.populate(query)
  end
end
