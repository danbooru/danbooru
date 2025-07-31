#!/usr/bin/env ruby

require_relative "base"

CurrentUser.user = User.system

fix = ENV.fetch("FIX", "false").truthy?
cond = ENV.fetch("COND", "true")

Post.joins(:votes).where(cond).where("post_votes.is_deleted = false").group(:id).having("posts.score != sum(post_votes.score)").find_each do |post|
  puts({
    id: post.id,
    score: post.score,
    up_score: post.votes.active.positive.sum(:score),
    down_score: post.votes.active.negative.sum(:score),
    true_score: post.votes.active.sum(:score),
  })

  if fix
    post.locked_update(
      score: post.votes.active.sum(:score),
      up_score: post.votes.active.positive.sum(:score),
      down_score: post.votes.active.negative.sum(:score),
    )
  end
end
