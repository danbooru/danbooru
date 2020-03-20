class ForumPostVotesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @forum_post_votes = authorize ForumPostVote.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @forum_post_votes = @forum_post_votes.includes(:creator, forum_post: [:creator, :topic]) if request.format.html?

    respond_with(@forum_post_votes)
  end

  def create
    @forum_post = ForumPost.find(params[:forum_post_id])
    @forum_post_vote = authorize ForumPostVote.new(creator: CurrentUser.user, forum_post: @forum_post, **permitted_attributes(ForumPostVote))
    @forum_post_vote.save
    respond_with(@forum_post_vote)
  end

  def destroy
    @forum_post_vote = authorize ForumPostVote.find(params[:id])
    @forum_post_vote.destroy
    respond_with(@forum_post_vote)
  end
end
