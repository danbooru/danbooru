#!/usr/bin/env ruby

require_relative "base"

CurrentUser.user = User.system

fix = ENV.fetch("FIX", "false").truthy?

Pool.find_each do |pool|
  pool.normalize_attribute(:name)
  next unless pool.changed?

  puts({
    id: pool.id,
    name: pool.name_change,
  }.to_json)

  pool.save! if fix
end

FavoriteGroup.find_each do |fav_group|
  fav_group.normalize_attribute(:name)
  next unless fav_group.changed?

  puts({
    id: fav_group.id,
    name: fav_group.name_change,
  }.to_json)

  fav_group.save! if fix
end
