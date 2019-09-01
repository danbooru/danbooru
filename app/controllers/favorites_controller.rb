class FavoritesController < ApplicationController
  before_action :member_only, except: [:index]
  respond_to :html, :xml, :json, :js
  skip_before_action :api_check
  rescue_with Favorite::Error, status: 422

  def index
    if params[:user_id].present?
      user = User.find(params[:user_id])
      redirect_to posts_path(tags: "ordfav:#{user.name}")
    elsif CurrentUser.is_member?
      redirect_to posts_path(tags: "ordfav:#{CurrentUser.name}")
    else
      redirect_to posts_path
    end
  end

  def create
    @post = Post.find(params[:post_id])
    @post.add_favorite!(CurrentUser.user)
    flash.now[:notice] = "You have favorited this post"

    respond_with(@post)
  end

  def destroy
    @post = Post.find_by_id(params[:id])

    if @post
      @post.remove_favorite!(CurrentUser.user)
    else
      Favorite.remove(post_id: params[:id], user: CurrentUser.user)
    end

    flash.now[:notice] = "You have unfavorited this post"
    respond_with(@post)
  end
end
