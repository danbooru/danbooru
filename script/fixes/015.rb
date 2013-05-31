#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

Pool.find_each do |pool|
  if pool.versions.count == 0
    pool.create_version(true)
  end
end
