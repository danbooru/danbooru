class PostModerationController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :janitor_only
  
  def moderate
    @search = Post.pending.available_for_moderation.search(params[:search]).order("id asc")
    @posts = @search.paginate(:page => params[:page])
    respond_with(@posts)
  end
  
  def approve
    @post = Post.find(params[:post_id])
    @post.approve!
    respond_with(@post, :location => post_moderation_moderate_path)
  end
  
  def disapprove
    @post = Post.find(params[:post_id])
    @post_disapproval = PostDisapproval.create(:post => @post, :user => CurrentUser.user)
    respond_with(@post_disapproval, :location => post_moderation_moderate_path)
  end
end
