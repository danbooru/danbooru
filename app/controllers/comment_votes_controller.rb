class CommentVotesController < ApplicationController
  respond_to :js, :json, :xml
  before_action :member_only
  skip_before_action :api_check
  rescue_with CommentVote::Error, ActiveRecord::RecordInvalid, status: 422

  def create
    @comment = Comment.find(params[:comment_id])
    @comment_vote = @comment.vote!(params[:score])
    respond_with(@comment)
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.unvote!
    respond_with(@comment)
  end
end
