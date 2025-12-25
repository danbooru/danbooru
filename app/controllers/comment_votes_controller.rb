# frozen_string_literal: true

class CommentVotesController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    @comment_votes = authorize CommentVote.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @comment_votes = @comment_votes.includes(:user, comment: [:creator, { post: [:uploader, :media_asset] }]) if request.format.html?

    comment_id = params[:comment_id] || params[:search][:comment_id]
    @comment = Comment.find(comment_id) if comment_id

    respond_with(@comment_votes)
  end

  def show
    @comment_vote = authorize CommentVote.find(params[:id])
    respond_with(@comment_vote)
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

    respond_with(@comment_vote)
  end

  def destroy
    @comment_vote = authorize CommentVote.find(params[:id])
    @comment_vote.soft_delete(updater: CurrentUser.user)

    respond_with(@comment_vote)
  end
end
