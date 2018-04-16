class ForumPostVotesController < ApplicationController
  respond_to :js
  before_action :load_forum_post
  before_action :load_vote, only: [:destroy]
  before_action :member_only

  def create
    @forum_post_vote = @forum_post.votes.create(forum_post_vote_params)
    respond_with(@forum_post_vote)
  end

  def destroy
    @forum_post_vote.destroy
    respond_with(@forum_post_vote)
  end

private
  
  def load_vote
    @forum_post_vote = @forum_post.votes.where(creator_id: CurrentUser.id).first
    raise ActiveRecord::RecordNotFound.new if @forum_post_vote.nil?
  end

  def load_forum_post
    @forum_post = ForumPost.find(params[:forum_post_id])
  end
  
  def forum_post_vote_params
    params.fetch(:forum_post_vote, {}).permit(:score)
  end

end
