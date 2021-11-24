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

    flash.now[:notice] = @post_vote.errors.full_messages.join("; ") if @post_vote.errors.present?
    respond_with(@post_vote)
  end

  def destroy
    if params[:post_id].present?
      @post_vote = PostVote.active.find_by(post_id: params[:post_id], user_id: CurrentUser.user)
      @post = Post.find(params[:post_id])
    else
      @post_vote = PostVote.find(params[:id])
      @post = @post_vote.post
    end

    if @post_vote.present?
      authorize(@post_vote).soft_delete(updater: CurrentUser.user)
      @post.reload
    end

    respond_with(@post_vote)
  end
end
