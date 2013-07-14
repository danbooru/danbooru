class FavoritesController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json

  def index
    if params[:tags]
      redirect_to(posts_path(:tags => params[:tags]))
    else
      user_id = params[:user_id] || CurrentUser.user.id
      @user = User.find(user_id)
      @favorite_set = PostSets::Favorite.new(user_id, params[:page], params)
      respond_with(@favorite_set.posts) do |format|
        format.xml do
          render :xml => @favorite_set.posts.to_xml(:root => "posts")
        end
      end
    end
  end

  def create
    if CurrentUser.favorite_limit.nil? || CurrentUser.favorite_count < CurrentUser.favorite_limit
      @post = Post.find(params[:post_id])
      @post.add_favorite!(CurrentUser.user)
    else
      @error_msg = "You can only keep up to #{CurrentUser.favorite_limit} favorites. Upgrade your account to save more."
    end
  end

  def destroy
    @post = Post.find(params[:id])
    @post.remove_favorite!(CurrentUser.user)
  end
end
