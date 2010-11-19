class FavoritesController < ApplicationController
  def index
    @posts = CurrentUser.favorite_posts(params)
  end
  
  def create
    @favorite = Favorite.create(
      :user_id => CurrentUser.id,
      :post_id => params[:favorite][:post_id]
    )
  end
  
  def destroy
    Favorite.destroy(
      :user_id => CurrentUser.id,
      :post_id => params[:favorite][:post_id]
    )
  end
end
