class PostModerationController < ApplicationController
  before_filter :janitor_only
  rescue_from Post::ApprovalError, :with => :approval_error
  rescue_from Post::DisapprovalError, :with => :disapproval_error
  
  def moderate
    @search = Post.pending.available_for_moderation.search(params[:search]).order("id asc")
    @posts = @search.paginate(:page => params[:page])
    respond_to do |format|
      format.html
      format.json {render :json => @posts.to_json}
    end
  end
  
  def approve
    @post = Post.find(params[:post_id])
    @post.approve!
    respond_to do |format|
      format.html {redirect_to(post_moderation_moderate_path, :notice => "Post approved")}
      format.js
    end
  end
  
  def disapprove
    @post = Post.find(params[:post_id])
    @post_disapproval = PostDisapproval.create(:post => @post, :user => CurrentUser.user)
    if @post_disapproval.errors.any?
      raise Post::DisapprovalError.new(@post_disapproval.errors.full_messages)
    end
    respond_to do |format|
      format.html {redirect_to(post_moderation_moderate_path, :notice => "Post disapproved")}
      format.js
    end
  end
  
  def delete
    @post = Post.find(params[:post_id])
    @post.delete!
  end
  
  def undelete
    @post = Post.find(params[:post_id])
    @post.undelete!
  end
  
private
  def disapproval_error(e)
    respond_to do |format|
      format.html {redirect_to(post_moderation_moderate_path, :notice => "You have already disapproved this post")}
      format.js {render :action => "disapproval_error"}
    end
  end
  
  def approval_error(e)
    respond_to do |format|
      format.html {redirect_to(post_moderation_moderate_path, :notice => e.message)}
      format.js {@exception = e; render :action => "approval_error"}
    end
  end
end
