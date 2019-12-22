#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

User.where("name like ?", "% %").find_each do |user|
  print "repairing #{user.name} -> "
  user.name = user.name.gsub(/[[:space:]]/, "_")
  user.save
  puts user.name
end
