class CommentVotesController < ApplicationController
  rescue_from CommentVote::Error, :with => :error
  
  def create
    @comment = Comment.find(params[:comment_id])
    @comment.vote!(params[:score])
    render :nothing => true
  end
  
private
  def error(exception)
    @exception = exception
    render :action => "error", :status => 500
  end
end
