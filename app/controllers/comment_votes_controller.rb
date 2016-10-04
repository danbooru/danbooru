class CommentVotesController < ApplicationController
  respond_to :js, :json, :xml
  before_filter :member_only

  def create
    @comment = Comment.find(params[:comment_id])
    @comment_vote = @comment.vote!(params[:score])
    respond_with(@comment_vote)
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.unvote!(params[:score])
  rescue CommentVote::Error => x
    @error = x
  end
end
