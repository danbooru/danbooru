class CommentVotesController < ApplicationController
  respond_to :js, :json, :xml
  before_action :member_only
  skip_before_action :api_check

  def create
    @comment = Comment.find(params[:comment_id])
    @comment_vote = @comment.vote!(params[:score])
  rescue CommentVote::Error, ActiveRecord::RecordInvalid => x
    @error = x
    render status: 422
  end

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.unvote!
  rescue CommentVote::Error => x
    @error = x
    render status: 422
  end
end
