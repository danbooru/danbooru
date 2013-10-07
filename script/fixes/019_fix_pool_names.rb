#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

admin = User.admins.first

CurrentUser.scoped(admin, "127.0.0.1") do
  Pool.where("name like ?", "%,%").find_each do |pool|
    pool.update_attribute(:name, pool.name.gsub(/,/, ""))
    pool.create_version(true)
  end
end

CurrentUser.scoped(admin, "127.0.0.1") do
  Pool.joins(:versions).where("pool_versions.name like ?", "%,%").uniq.find_each do |pool|
    pool.create_version(true)
  end
end
