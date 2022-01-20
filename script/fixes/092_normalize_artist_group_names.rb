#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system) do
    Artist.where.not(group_name: "").find_each do |artist|
      artist.update!(group_name: artist.group_name) # forces normalization

      if artist.saved_changes?
        puts "id=#{artist.id} name=#{artist.name} oldgroup=`#{artist.group_name_before_last_save}` newgroup=`#{artist.group_name}`"
      end
    rescue ActiveRecord::RecordInvalid
      puts "id=#{artist.id} name=#{artist.name} error=#{artist.errors.full_messages.join}"
    end
  end
end
