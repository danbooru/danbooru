#!/usr/bin/env ruby

require_relative "../../config/environment"

PostFlag.transaction do
  # Mark all old flags and appeals as succeeded or rejected. Recent flags and
  # appeals are left as pending. This is not strictly correct for posts that
  # may have been flagged or appealed multiple times.
  PostAppeal.expired.where(post: Post.undeleted).update_all(status: "succeeded")
  PostAppeal.expired.where(post: Post.deleted).update_all(status: "rejected")
  PostFlag.where(post: Post.undeleted).update_all(status: "rejected")
  PostFlag.where(post: Post.deleted).update_all(status: "succeeded")

  # Mark all unapproved in three days flags as successful.
  PostFlag.category_matches("deleted").update_all(status: "succeeded")

  # Mark all currently flagged posts as pending.
  PostFlag.where(post: Post.flagged).update_all(status: "pending")

  puts "Appeals pending: #{PostAppeal.pending.count}"
  puts "Appeals succeeded: #{PostAppeal.succeeded.count}"
  puts "Appeals rejected: #{PostAppeal.rejected.count}"
  puts "Flags pending: #{PostFlag.pending.count}"
  puts "Flags succeeded: #{PostFlag.succeeded.count}"
  puts "Flags rejected: #{PostFlag.rejected.count}"
end
