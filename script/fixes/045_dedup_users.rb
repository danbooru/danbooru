#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

candidates = User.group("lower(name)").having("count(*) > 1").pluck("lower(name)")

candidates.each do |name|
  users = User.where("lower(name) = ?", name).order("id").to_a
  users.slice(1, 100).each do |user|
    user.name = "dup_#{user.name}_#{user.id}"
    user.save!
  end
end
