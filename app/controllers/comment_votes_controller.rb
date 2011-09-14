class CommentVotesController < ApplicationController
  respond_to :js
  
  def create
    @comment = Comment.find(params[:comment_id])
    @comment_vote = @comment.vote!(params[:score])
    respond_with(@comment_vote)
  end
end
