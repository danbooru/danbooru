class Mobile::PostsController < ApplicationController
  layout "mobile"
  before_filter :set_mobile_mode
  
  def index
    @post_set = PostSets::Post.new(params[:tags], params[:page], CurrentUser.user.per_page, raw: false)
    @posts = @post_set.posts
  end

  def show
    @post = Post.find(params[:id])
  end

private
  def set_mobile_mode
    CurrentUser.mobile_mode = true
  end
end
