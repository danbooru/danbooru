#!/usr/bin/env ruby

require_relative "../../config/environment"

CurrentUser.scoped(User.system) do
  WikiPage.transaction do
    WikiPage.find_each do |wp|
      old_other_names = wp.other_names
      wp.other_names = old_other_names

      if wp.changed?
        p [wp.id, wp.changes]
        wp.save!
      end
    end
  end
end
