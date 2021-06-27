# A job that updates a user's saved searches when they do a search for
# `search:all` or `search:<label>`.
class PopulateSavedSearchJob < ApplicationJob
  queue_as :default

  def perform(query)
    SavedSearch.populate(query)
  end
end
