# frozen_string_literal: true

class FavoritesController < ApplicationController
  respond_to :js, :json, :html, :xml

  def index
    post_id = params[:post_id] || params[:search][:post_id]
    user_id = params[:user_id] || params[:search][:user_id]
    user_name = params[:search][:user_name]
    @post = Post.find(post_id) if post_id
    @user = User.find(user_id) if user_id
    @user = User.find_by_name(user_name) if user_name

    @favorites = authorize Favorite.visible(CurrentUser.user).paginated_search(params, defaults: { post_id: @post&.id, user_id: @user&.id })
    respond_with(@favorites)
  end

  def create
    @favorite = authorize Favorite.new(post_id: params[:post_id], user: CurrentUser.user)
    @favorite.save
    @post = @favorite.post.reload

    respond_with(@post, notice: "You have favorited this post")
  end

  def destroy
    @favorite = authorize Favorite.find_by!(post_id: params[:id], user: CurrentUser.user)
    @favorite.destroy
    @post = @favorite.post.reload

    respond_with(@post, notice: "You have unfavorited this post")
  end
end
