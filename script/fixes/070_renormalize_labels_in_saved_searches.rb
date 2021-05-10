#!/usr/bin/env ruby

require_relative "../../config/environment"

SavedSearch.transaction do
  SavedSearch.find_each do |ss|
    old_labels = ss.labels
    ss.labels = old_labels

    if ss.changed?
      p [ss.id, ss.changes]
      ss.save!
    end
  end
end
