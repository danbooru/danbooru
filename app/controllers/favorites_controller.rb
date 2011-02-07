class FavoritesController < ApplicationController
  def index
    if params[:tags]
      redirect_to(posts_path(:tags => "fav:#{CurrentUser.name} #{params[:tags]}"))
    else
      @post_set = PostSets::Favorite.new(CurrentUser.user)
    end
  end
  
  def create
    Post.find(params[:id]).add_favorite(CurrentUser.user)
    render :nothing => true
  end
  
  def destroy
    Post.find(params[:id]).remove_favorite(CurrentUser.user)
    render :nothing => true
  end
end
