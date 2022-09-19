#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  ModAction.user_delete.where_regex(:description, "^user #[0-9]+ deleted$"). find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\Auser #([0-9]+) deleted\z/, 'deleted user #\1'))
    puts ma.description
  end

  ModAction.user_approval_privilege.where_regex(:description, '^".+":/users/[0-9]+ changed approval privileges for ".*":/users/[0-9]+ from false to \[b\]true\[/b\]$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A".+":\/users\/[0-9]+ changed approval privileges for "(.+)":\/users\/([0-9]+) from false to \[b\]true\[\/b\]\z/, 'granted approval privileges to "\1":/users/\2'))
    puts ma.description
  end

  ModAction.user_approval_privilege.where_regex(:description, '^".+":/users/[0-9]+ changed approval privileges for ".*":/users/[0-9]+ from true to \[b\]false\[/b\]$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A".+":\/users\/[0-9]+ changed approval privileges for "(.+)":\/users\/([0-9]+) from true to \[b\]false\[\/b\]\z/, 'removed approval privileges from "\1":/users/\2'))
    puts ma.description
  end

  ModAction.user_upload_privilege.where_regex(:description, '^".+":/users/[0-9]+ changed unlimited upload privileges for ".*":/users/[0-9]+ from false to \[b\]true\[/b\]$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A".+":\/users\/[0-9]+ changed unlimited upload privileges for "(.+)":\/users\/([0-9]+) from false to \[b\]true\[\/b\]\z/, 'granted unlimited upload privileges to "\1":/users/\2'))
    puts ma.description
  end

  ModAction.user_upload_privilege.where_regex(:description, '^".+":/users/[0-9]+ changed unlimited upload privileges for ".*":/users/[0-9]+ from true to \[b\]false\[/b\]$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A".+":\/users\/[0-9]+ changed unlimited upload privileges for "(.+)":\/users\/([0-9]+) from true to \[b\]false\[\/b\]\z/, 'removed unlimited upload privileges from "\1":/users/\2'))
    puts ma.description
  end

  ModAction.user_level_change.where_regex(:description, '^".+":/users/[0-9]+ level changed .* -> .*$').find_each do |ma|
    ma.description =~ /\A"(.+)":\/users\/([0-9]+) level changed (.*) -> (.*)\z/
    old_level = User.level_hash[$3]
    new_level = User.level_hash[$4]

    if old_level < new_level
      ma.update_columns(description: "promoted \"#{$1}\":/users/#{$2} from #{$3} to #{$4}")
    else
      ma.update_columns(description: "demoted \"#{$1}\":/users/#{$2} from #{$3} to #{$4}")
    end

    puts ma.description
  end

  ModAction.user_account_upgrade.where_regex(:description, '^".+":/users/[0-9]+ level changed .* -> .*$').find_each do |ma|
    ma.description =~ /\A"(.+)":\/users\/([0-9]+) level changed (.*) -> (.*)\z/
    recipient_id = $2.to_i

    if recipient_id == ma.creator_id
      ma.update_columns(description: "upgraded from #{$3} to #{$4}")
    else
      ma.update_columns(description: "upgraded \"#{$1}\":/users/#{$2} from #{$3} to #{$4}")
    end

    puts ma.description
  end

  ModAction.user_ban.where_regex(:description, '^Banned').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\ABanned/, "banned"))
    puts ma.description
  end

  ModAction.user_unban.where_regex(:description, '^Unbanned').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\AUnbanned/, "unbanned"))
    puts ma.description
  end

  ModAction.comment_update.where_regex(:description, '^comment #[0-9]+ updated by').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\Acomment #([0-9]+) updated by .+\z/, 'updated comment #\1'))
    puts ma.description
  end

  ModAction.comment_delete.where_regex(:description, '^comment #[0-9]+ deleted by').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\Acomment #([0-9]+) deleted by .+\z/, 'deleted comment #\1'))
    puts ma.description
  end

  ModAction.comment_vote_delete.where_regex(:description, '^.+ deleted comment vote #[0-9]+ on comment #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.+ deleted comment vote #([0-9]+) on comment #([0-9]+)\z/, 'deleted comment vote #\1 on comment #\2'))
    puts ma.description
  end

  ModAction.forum_post_update.where_regex(:description, '^.* updated forum #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.* updated forum #([0-9]+)\z/, 'updated forum #\1'))
    puts ma.description
  end

  ModAction.forum_post_delete.where_regex(:description, '^.* deleted forum #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.* deleted forum #([0-9]+)\z/, 'deleted forum #\1'))
    puts ma.description
  end

  ModAction.ip_ban_create.where_regex(:description, '^.* created ip ban for .*$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.* created ip ban for (.*)\z/, 'created ip ban for \1'))
    puts ma.description
  end

  ModAction.ip_ban_delete.where_regex(:description, '^.* deleted ip ban for .*$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.* deleted ip ban for (.*)\z/, 'deleted ip ban for \1'))
    puts ma.description
  end

  ModAction.ip_ban_undelete.where_regex(:description, '^.* undeleted ip ban for .*$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.* undeleted ip ban for (.*)\z/, 'undeleted ip ban for \1'))
    puts ma.description
  end

  ModAction.post_vote_delete.where_regex(:description, '^.+ deleted post vote #[0-9]+ on post #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.+ deleted post vote #([0-9]+) on post #([0-9]+)\z/, 'deleted post vote #\1 on post #\2'))
    puts ma.description
  end

  ModAction.user_feedback_update.where_regex(:description, '^.+ updated user feedback for ".+":/users/[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.+ updated user feedback for "(.+)":\/users\/([0-9]+)\z/, 'updated user feedback for "\1":/users/\2'))
    puts ma.description
  end

  ModAction.user_feedback_delete.where_regex(:description, '^.+ deleted user feedback for ".+":/users/[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A.+ deleted user feedback for "(.+)":\/users\/([0-9]+)\z/, 'deleted user feedback for "\1":/users/\2'))
    puts ma.description
  end

  ModAction.post_regenerate_iqdb.where_regex(:description, '^<@.*> regenerated IQDB for post #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A<@.*> regenerated IQDB for post #([0-9]+)$/, 'regenerated IQDB for post #\1'))
    puts ma.description
  end

  ModAction.post_regenerate.where_regex(:description, '^<@.*> regenerated image samples for post #[0-9]+$').find_each do |ma|
    ma.update_columns(description: ma.description.gsub(/\A<@.*> regenerated image samples for post #([0-9]+)$/, 'regenerated image samples for post #\1'))
    puts ma.description
  end
end
