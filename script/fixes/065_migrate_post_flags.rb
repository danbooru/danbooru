#!/usr/bin/env ruby

require_relative "../../config/environment"

CurrentUser.user = User.system

Post.transaction do
  Post.where(is_rating_locked: true).each do |post|
    post.create_or_update_lock({rating_lock: true, reason: "Value migrated by system."})
    puts "Rating lock: post ##{post.id}"
  end
  Post.where(is_note_locked: true).each do |post|
    post.create_or_update_lock({notes_lock: true, reason: "Value migrated by system."})
    puts "Note lock: post ##{post.id}"
  end
  Post.where(is_status_locked: true).each do |post|
    post.create_or_update_lock({status_lock: true, reason: "Value migrated by system."})
    puts "Status lock: post ##{post.id}"
  end
end
