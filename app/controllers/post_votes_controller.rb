class PostVotesController < ApplicationController
  def create
    @post = Post.find(params[:post_id])
    @post.vote!(params[:score])
  rescue PostVote::Error => x
    @error = x
  end
  
  def destroy
  end
end
