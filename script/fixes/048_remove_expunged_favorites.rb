#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment'))

CurrentUser.user = User.system
CurrentUser.ip_addr = "127.0.0.1"

ModAction.without_timeout do
  ModAction.where(creator_id: 1).where("created_at > ? and description like ?", "2017-07-18", "permanently deleted post%").find_each do |ma|
    post_id = ma.description.scan(/\d+/).first
    puts "deleting favorites for #{post_id}"
    Favorite.destroy_all(post_id: post_id)
  end
end
