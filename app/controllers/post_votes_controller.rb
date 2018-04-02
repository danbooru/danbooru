class PostVotesController < ApplicationController
  before_action :voter_only
  skip_before_action :api_check

  def create
    @post = Post.find(params[:post_id])
    @post.vote!(params[:score])
  rescue PostVote::Error, ActiveRecord::RecordInvalid => x
    @error = x
    render status: 500
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.unvote!
  rescue PostVote::Error => x
    @error = x
    render status: 500
  end
end
