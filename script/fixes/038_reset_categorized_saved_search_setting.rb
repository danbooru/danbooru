#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

ActiveRecord::Base.connection.execute("set statement_timeout = 0")

CurrentUser.user = User.admins.first
CurrentUser.ip_addr = "127.0.0.1"

User.where("bit_prefs & ? > 0", User.flag_value_for("disable_categorized_saved_searches")).find_each do |user|
  user.disable_categorized_saved_searches = false
  user.save
end
