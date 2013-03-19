#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")
Tag.find_each do |tag|
  tag.fix_post_count
end

ActiveRecord::Base.connection.execute("update comments set updater_id = creator_id where updater_id <> creator_id")
