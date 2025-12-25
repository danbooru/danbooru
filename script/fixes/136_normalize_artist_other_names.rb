#!/usr/bin/env ruby

require_relative "base"

fix = ENV.fetch("FIX", "false").truthy?
CurrentUser.user = User.system

artists = Artist.where("other_names @> ARRAY[name]::text[]")
artists.find_each do |artist|
  artist.other_names = artist.other_names

  puts ({ id: artist.id, name: artist.name, removed: artist.other_names_was - artist.other_names, other_names: artist.other_names }).compact_blank.to_json
  artist.save! if fix
end
