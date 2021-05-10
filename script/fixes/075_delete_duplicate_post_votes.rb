#!/usr/bin/env ruby

require_relative "../../config/environment"

PostVote.transaction do
  PostVote.group(:post_id, :user_id).having("count(*) > 1").count.each do |(post_id, user_id), count|
    votes = PostVote.where(post_id: post_id, user_id: user_id).order(:id)

    # Remove all but the first duplicate vote.
    dupe_votes = votes.drop(1)
    dupe_votes.each { p _1 }
    dupe_votes.each(&:destroy)
  end
end
