#!/usr/bin/env ruby

require_relative "base"

User.where_regex(:blacklisted_tags, "furry -rating:s").find_each do |user|
  blacklist = user.blacklisted_tags.gsub(/(\n|\r|^)furry -rating:s(\n|\r|$)/i, '\1furry -rating:g\2').strip
  user.update!(blacklisted_tags: blacklist)
  puts "id=#{user.id} blacklist='#{blacklist.split(/(?:\n|\r)+/).join('\n')}'"
end
