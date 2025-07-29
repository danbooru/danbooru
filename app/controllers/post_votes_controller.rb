# frozen_string_literal: true

class PostVotesController < ApplicationController
  respond_to :js, :json, :xml, :html

  def index
    @post_votes = authorize PostVote.visible(CurrentUser.user).paginated_search(params)
    @post_votes = @post_votes.includes(:user, post: [:uploader, :media_asset]) if request.format.html?
    @post = Post.find(params.dig(:search, :post_id)) if params.dig(:search, :post_id).present?

    respond_with(@post_votes)
  end

  def show
    @post_vote = authorize PostVote.find(params[:id])
    respond_with(@post_vote)
  end

  def create
    @post_vote = authorize PostVote.new(post_id: params[:post_id], score: params[:score], user: CurrentUser.user)
    @post_vote.save
    @post = @post_vote.post.reload

    respond_with(@post_vote)
  end

  def destroy
    @post_vote = authorize PostVote.find(params[:id])
    @post_vote.locked_update(is_deleted: true, updater: CurrentUser.user)
    @post = @post_vote.post.reload

    respond_with(@post_vote)
  end
end
