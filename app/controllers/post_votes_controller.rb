class PostVotesController < ApplicationController
  before_action :voter_only
  skip_before_action :api_check
  respond_to :js, :json, :xml, :html
  rescue_with PostVote::Error, status: 422

  def index
    @post_votes = PostVote.paginated_search(params, count_pages: true)
    @post_votes = @post_votes.includes(:user, post: :uploader) if request.format.html?

    respond_with(@post_votes)
  end

  def create
    @post = Post.find(params[:post_id])
    @post.vote!(params[:score])

    respond_with(@post)
  end

  def destroy
    @post = Post.find(params[:post_id])
    @post.unvote!

    respond_with(@post)
  end
end
