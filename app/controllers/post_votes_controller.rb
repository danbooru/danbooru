class PostVotesController < ApplicationController
  before_filter :voter_only
  skip_before_filter :api_check

  def create
    @post = Post.find(params[:post_id])
    @post.vote!(params[:score])
  rescue PostVote::Error => x
    @error = x
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.unvote!
  rescue PostVote::Error => x
    @error = x
  end
end
