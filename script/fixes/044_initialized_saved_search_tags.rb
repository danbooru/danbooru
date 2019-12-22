#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

SavedSearch.find_each do |ss|
  ss.labels = [ss.category]
  ss.save
end
