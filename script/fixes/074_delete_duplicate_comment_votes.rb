#!/usr/bin/env ruby

require_relative "../../config/environment"

CommentVote.transaction do
  CommentVote.group(:comment_id, :user_id).having("count(*) > 1").count.each do |(comment_id, user_id), count|
    votes = CommentVote.where(comment_id: comment_id, user_id: user_id).order(:id)

    # Remove all but the first duplicate vote.
    dupe_votes = votes.drop(1)
    dupe_votes.each { p _1 }
    dupe_votes.each(&:destroy)
  end
end
