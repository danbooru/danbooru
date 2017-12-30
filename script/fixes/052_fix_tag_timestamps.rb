#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

Tag.transaction do
  Tag.without_timeout do
    puts "Tag.where(updated_at: nil).count = #{Tag.where(updated_at: nil).count}"
    puts "Tag.where(created_at: nil).count = #{Tag.where(created_at: nil).count}"

    Tag.where(updated_at: nil).update_all(updated_at: Time.zone.now)
    Tag.where(created_at: nil).update_all("created_at = updated_at")
  end
end
