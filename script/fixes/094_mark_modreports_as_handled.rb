#!/usr/bin/env ruby

require_relative "base"

with_confirmation do
  ModerationReport.pending.where(model: Comment.deleted).update_all(status: :handled, updated_at: Time.zone.now)
  ModerationReport.pending.where(model: ForumPost.deleted).update_all(status: :handled, updated_at: Time.zone.now)
  ModerationReport.pending.where(model: Dmail.deleted).update_all(status: :handled, updated_at: Time.zone.now)
end
