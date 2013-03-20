#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

ActiveRecord::Base.connection.execute("update comments set updater_id = creator_id where updater_id <> creator_id")

Tag.where("id > 519653").find_each do |tag|
  tag.fix_post_count
end
