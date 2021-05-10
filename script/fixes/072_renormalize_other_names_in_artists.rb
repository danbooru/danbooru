#!/usr/bin/env ruby

require_relative "../../config/environment"

CurrentUser.scoped(User.system) do
  Artist.transaction do
    Artist.find_each do |artist|
      old_other_names = artist.other_names
      artist.other_names = old_other_names

      if artist.changed?
        p [artist.id, artist.changes]
        artist.save!
      end
    end
  end
end
