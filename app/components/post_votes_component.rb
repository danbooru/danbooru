# frozen_string_literal: true

# This component represents the post score and upvote/downvote buttons ("🠉 5 🠋")
class PostVotesComponent < ApplicationComponent
  attr_reader :post, :current_user

  def initialize(post:, current_user:)
    super
    @post = post
    @current_user = current_user
  end

  def can_vote?
    policy(PostVote).create?
  end

  # Return to the same page of search results after logging in. Long searches are left out, since this link is repeated
  # for every post on the page. Post pages don't need any params.
  def login_url
    login_path(url: current_path_with(page: current_page_param, tags: request.query_parameters["tags"]))
  end

  def current_vote
    post.vote_by_current_user
  end

  def upvoted?
    can_vote? && current_vote&.is_positive?
  end

  def downvoted?
    can_vote? && current_vote&.is_negative?
  end
end
