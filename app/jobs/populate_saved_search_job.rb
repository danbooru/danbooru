class PopulateSavedSearchJob < ApplicationJob
  queue_as :default

  def perform(query)
    SavedSearch.populate(query)
  end
end
