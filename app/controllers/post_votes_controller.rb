class PostVotesController < ApplicationController
  skip_before_action :api_check
  respond_to :js, :json, :xml, :html

  def index
    @post_votes = authorize PostVote.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @post_votes = @post_votes.includes(:user, post: :uploader) if request.format.html?

    respond_with(@post_votes)
  end

  def create
    @post = Post.find(params[:post_id])

    @post.with_lock do
      @post_vote = authorize PostVote.new(post: @post, score: params[:score], user: CurrentUser.user)
      PostVote.where(post: @post, user: CurrentUser.user).destroy_all
      @post_vote.save
    end

    flash.now[:notice] = @post_vote.errors.full_messages.join("; ") if @post_vote.errors.present?
    respond_with(@post_vote)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post_vote = @post.votes.find_by(user: CurrentUser.user)

    authorize(@post_vote).destroy if @post_vote
    respond_with(@post_vote)
  end
end
