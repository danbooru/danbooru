class CommentVotesController < ApplicationController
  skip_before_action :api_check
  respond_to :js, :json, :xml, :html
  rescue_with CommentVote::Error, ActiveRecord::RecordInvalid, status: 422

  def index
    @comment_votes = authorize CommentVote.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @comment_votes = @comment_votes.includes(:user, comment: [:creator, post: [:uploader]]) if request.format.html?
    respond_with(@comment_votes)
  end

  def create
    @comment = authorize Comment.find(params[:comment_id]), policy_class: CommentVotePolicy
    @comment_vote = @comment.vote!(params[:score])
    respond_with(@comment)
  end

  def destroy
    @comment = authorize Comment.find(params[:comment_id]), policy_class: CommentVotePolicy
    @comment.unvote!
    respond_with(@comment)
  end
end
