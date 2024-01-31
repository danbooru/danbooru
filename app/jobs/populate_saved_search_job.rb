# frozen_string_literal: true

# A job that updates a user's saved searches when they do a search for
# `search:all` or `search:<label>`.
class PopulateSavedSearchJob < ApplicationJob
  queue_with_priority 10

  def perform(query)
    SavedSearch.populate(query)
  end
end
