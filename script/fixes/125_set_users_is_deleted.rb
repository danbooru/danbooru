#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  deleted_users = User.where_regex(:name, "^user_[0-9]+~*$").where(is_deleted: false)

  deleted_users.find_each do |user|
    puts user.attributes.slice("id", "name", "level", "created_at", "last_logged_in_at").to_json
  end

  deleted_users.update_all(is_deleted: true) if ENV.fetch("FIX", "false").truthy?
end
