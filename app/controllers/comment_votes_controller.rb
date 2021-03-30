class CommentVotesController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    @comment_votes = authorize CommentVote.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @comment_votes = @comment_votes.includes(:user, comment: [:creator, post: [:uploader]]) if request.format.html?

    respond_with(@comment_votes)
  end

  def create
    @comment = Comment.find(params[:comment_id])

    @comment.with_lock do
      @comment_vote = authorize CommentVote.new(comment: @comment, score: params[:score], user: CurrentUser.user)

      CommentVote.active.where(comment: @comment, user: CurrentUser.user).each do |vote|
        vote.soft_delete!(updater: CurrentUser.user)
      end

      @comment_vote.save
    end

    flash.now[:notice] = @comment_vote.errors.full_messages.join("; ") if @comment_vote.errors.present?
    respond_with(@comment_vote)
  end

  def destroy
    # XXX should find by comment vote id.
    @comment_vote = authorize CommentVote.active.find_by!(comment_id: params[:comment_id], user: CurrentUser.user)
    @comment_vote.soft_delete(updater: CurrentUser.user)

    respond_with(@comment_vote)
  end
end
