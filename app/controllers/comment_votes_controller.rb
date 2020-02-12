class CommentVotesController < ApplicationController
  before_action :member_only
  skip_before_action :api_check
  respond_to :js, :json, :xml, :html
  rescue_with CommentVote::Error, ActiveRecord::RecordInvalid, status: 422

  def index
    @comment_votes = CommentVote.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@comment_votes)
  end

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

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:user, {comment: [:creator, {post: [:uploader]}]}]
    end
  end
end
