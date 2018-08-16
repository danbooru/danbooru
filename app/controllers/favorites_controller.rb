class FavoritesController < ApplicationController
  before_action :member_only, except: [:index]
  respond_to :html, :xml, :json, :js
  skip_before_action :api_check

  def index
    if params[:tags]
      redirect_to(posts_path(:tags => params[:tags]))
    else
      user_id = params[:user_id] || CurrentUser.user.id
      @user = User.find(user_id)

      if @user.hide_favorites?
        raise User::PrivilegeError.new
      end

      @favorite_set = PostSets::Favorite.new(user_id, params[:page], params)
      respond_with(@favorite_set.posts) do |format|
        format.xml do
          render :xml => @favorite_set.posts.to_xml(:root => "posts")
        end
      end
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
