class FavoritesController < ApplicationController
  respond_to :html, :xml, :json, :js
  skip_before_action :api_check
  rescue_with Favorite::Error, status: 422

  def index
    authorize Favorite
    if !request.format.html?
      @favorites = Favorite.visible(CurrentUser.user).paginated_search(params)
      respond_with(@favorites)
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      redirect_to posts_path(tags: "ordfav:#{user.name}", format: request.format.symbol)
    elsif CurrentUser.is_member?
      redirect_to posts_path(tags: "ordfav:#{CurrentUser.name}", format: request.format.symbol)
    else
      redirect_to posts_path(format: request.format.symbol)
    end
  end

  def create
    authorize Favorite
    @post = Post.find(params[:post_id])
    @post.add_favorite!(CurrentUser.user)
    flash.now[:notice] = "You have favorited this post"

    respond_with(@post)
  end

  def destroy
    authorize Favorite
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
