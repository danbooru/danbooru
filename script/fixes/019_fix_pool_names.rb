#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Pool.where("name like ?", "%,%").find_each do |pool|
  pool.update_attribute(:name, pool.name.gsub(/,/, ""))
  pool.create_version(true)
end
