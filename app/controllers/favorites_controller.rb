class FavoritesController < ApplicationController
  def index
    if params[:tags]
      redirect_to(posts_path(:tags => "fav:#{CurrentUser.name} #{params[:tags]}"))
    else
      @posts = PostSets::Favorite.new(CurrentUser.user)
    end
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
