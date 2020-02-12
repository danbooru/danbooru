class PostVotesController < ApplicationController
  before_action :voter_only
  skip_before_action :api_check
  respond_to :js, :json, :xml, :html
  rescue_with PostVote::Error, status: 422

  def index
    @post_votes = PostVote.paginated_search(params, count_pages: true).includes(model_includes(params))
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

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:user, {post: [:uploader]}]
    end
  end
end
