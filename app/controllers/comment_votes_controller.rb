class CommentVotesController < ApplicationController
  def create
    @comment = Comment.find(params[:comment_id])
    @comment.vote!(params[:score])
  rescue CommentVote::Error => x
    @error = x
  end
end
