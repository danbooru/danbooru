class FavoritesController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    authorize Favorite
    if !request.format.html?
      @favorites = Favorite.visible(CurrentUser.user).paginated_search(params)
      respond_with(@favorites)
    elsif params[:user_id].present?
      user = User.find(params[:user_id])
      redirect_to posts_path(tags: "ordfav:#{user.name}", format: request.format.symbol)
    elsif !CurrentUser.is_anonymous?
      redirect_to posts_path(tags: "ordfav:#{CurrentUser.user.name}", format: request.format.symbol)
    else
      redirect_to posts_path(format: request.format.symbol)
    end
  end

  def create
    @favorite = authorize Favorite.new(post_id: params[:post_id], user: CurrentUser.user)
    @favorite.save
    @post = @favorite.post.reload

    flash.now[:notice] = "You have favorited this post"
    respond_with(@post)
  end

  def destroy
    @favorite = authorize Favorite.find_by!(post_id: params[:id], user: CurrentUser.user)
    @favorite.destroy
    @post = @favorite.post.reload

    flash.now[:notice] = "You have unfavorited this post"
    respond_with(@post)
  end
end
