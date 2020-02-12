class ForumPostVotesController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, only: [:create, :destroy]

  def index
    @forum_post_votes = ForumPostVote.paginated_search(params, count_pages: true).includes(model_includes(params))
    respond_with(@forum_post_votes)
  end

  def create
    @forum_post = ForumPost.find(params[:forum_post_id])
    @forum_post_vote = @forum_post.votes.create(forum_post_vote_params.merge(creator: CurrentUser.user))
    respond_with(@forum_post_vote)
  end

  def destroy
    @forum_post_vote = CurrentUser.user.forum_post_votes.find(params[:id])
    @forum_post_vote.destroy
    respond_with(@forum_post_vote)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:creator, {forum_post: [:topic]}]
    end
  end

  def forum_post_vote_params
    params.fetch(:forum_post_vote, {}).permit(:score)
  end
end
