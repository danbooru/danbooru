class FavoritesController < ApplicationController
  before_filter :member_only
  
  def index
    if params[:tags]
      redirect_to(posts_path(:tags => "fav:#{CurrentUser.name} #{params[:tags]}"))
    else
      @favorite_set = PostSets::Favorite.new(CurrentUser.user, params[:page])
    end
  end
  
  def create
    Post.find(params[:post_id]).add_favorite!(CurrentUser.user)
  end
  
  def destroy
    Post.find(params[:id]).remove_favorite!(CurrentUser.user)
  end
end
