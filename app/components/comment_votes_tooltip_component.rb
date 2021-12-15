# frozen_string_literal: true

# This component represents the tooltip that displays when you hover over a comment's score.
class CommentVotesTooltipComponent < ApplicationComponent
  attr_reader :comment, :current_user
  delegate :upvote_icon, :downvote_icon, to: :helpers

  def initialize(comment:, current_user:)
    super
    @comment = comment
    @current_user = current_user
  end

  def votes
    comment.votes.active.includes(:user).order(id: :desc)
  end

  def upvote_count
    votes.select(&:is_positive?).length
  end

  def downvote_count
    votes.select(&:is_negative?).length
  end

  def upvote_ratio
    return nil if votes.length == 0
    sprintf("(%.1f%%)", 100.0 * upvote_count / votes.length)
  end

  def vote_icon(vote)
    vote.is_positive? ? upvote_icon : downvote_icon
  end
end
