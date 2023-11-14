#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  User.where(level: User::Levels::BUILDER).bit_prefs_match(:_unused_can_upload_free, true).bit_prefs_match(:_unused_can_approve_posts, false).find_each do |contributor|
    contributor.level = User::Levels::CONTRIBUTOR
    contributor.save
    puts "user ##{contributor.id} #{contributor.name} updated to contributor"
  end

  User.where(level: User::Levels::BUILDER).bit_prefs_match(:_unused_can_approve_posts, true).find_each do |approver|
    approver.level = User::Levels::APPROVER
    approver.save
    puts "user ##{approver.id} #{approver.name} updated to approver"
  end
end
