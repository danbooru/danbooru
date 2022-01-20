#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  CurrentUser.scoped(User.system) do
    Artist.where("name ~ '[^[:ascii:]]'").find_each do |artist|
      artist.other_names += [artist.name]
      artist.name = "artist_#{artist.id}"
      artist.is_deleted = true
      artist.save!

      if artist.saved_changes?
        puts "id=#{artist.id} oldname=#{artist.name_before_last_save} newname=`#{artist.name}` other_names=#{artist.other_names}"
      end
    rescue ActiveRecord::RecordInvalid
      puts "id=#{artist.id} name=#{artist.name} error=#{artist.errors.full_messages.join}"
    end
  end
end
