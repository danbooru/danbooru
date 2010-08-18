class FavoritesController < ApplicationController
  def create
    @favorite = Favorite.create(
      :user_id => @current_user.id,
      :post_id => params[:favorite][:post_id]
    )
  end
  
  def destroy
    Favorite.destroy(
      :user_id => @current_user.id,
      :post_id => params[:favorite][:post_id]
    )
  end
end
