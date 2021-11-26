# frozen_string_literal: true

# This component represents the tooltip that displays when you hover over a post's score.
class PostVotesTooltipComponent < ApplicationComponent
  attr_reader :post, :current_user
  delegate :upvote_icon, :downvote_icon, to: :helpers

  def initialize(post:, current_user:)
    super
    @post = post
    @current_user = current_user
  end

  def votes
    @post.votes.active.includes(:user).order(id: :desc)
  end

  def vote_icon(vote)
    vote.is_positive? ? upvote_icon : downvote_icon
  end

  def vote_count
    post.up_score + post.down_score.abs
  end

  def upvote_ratio
    return nil if vote_count == 0
    sprintf("(%.1f%%)", 100.0 * post.up_score / vote_count)
  end

  def voter_name(vote)
    if policy(vote).can_see_voter?
      link_to_user(vote.user, classes: "align-middle")
    else
      tag.i("hidden", class: "align-middle")
    end
  end
end
