#!/usr/bin/env ruby

require_relative "../../config/environment"

User.transaction do
  users = User.where("comment_threshold > ?", User.anonymous.comment_threshold)
  p users.count
  users.update_all(comment_threshold: User.anonymous.comment_threshold)

  users = User.where("comment_threshold < ?", -100)
  p users.count
  users.update_all(comment_threshold: -100)
end
