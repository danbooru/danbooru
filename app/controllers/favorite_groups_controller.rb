# frozen_string_literal: true

class FavoriteGroupsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    params[:search][:creator_id] ||= params[:user_id]
    @favorite_groups = authorize FavoriteGroup.visible(CurrentUser.user).paginated_search(params)
    @favorite_groups = @favorite_groups.includes(:creator) if request.format.html?

    respond_with(@favorite_groups)
  end

  def show
    limit = params[:limit].presence || CurrentUser.user.per_page

    @favorite_group = authorize FavoriteGroup.find(params[:id])
    @posts = @favorite_group.posts.paginate(params[:page], limit: limit, count: @favorite_group.post_count)

    respond_with(@favorite_group)
  end

  def new
    @favorite_group = authorize FavoriteGroup.new(creator: CurrentUser.user)
    respond_with(@favorite_group)
  end

  def create
    @favorite_group = authorize FavoriteGroup.new(creator: CurrentUser.user, **permitted_attributes(FavoriteGroup))
    @favorite_group.save
    respond_with(@favorite_group)
  end

  def edit
    @favorite_group = authorize FavoriteGroup.find(params[:id])
    respond_with(@favorite_group)
  end

  def update
    @favorite_group = authorize FavoriteGroup.find(params[:id])
    @favorite_group.update(permitted_attributes(@favorite_group))

    respond_with(@favorite_group, notice: "Favorite group updated")
  end

  def destroy
    @favorite_group = authorize FavoriteGroup.find(params[:id])
    @favorite_group.destroy!

    respond_with(@favorite_group, notice: "Favorite group deleted", location: favorite_groups_path(search: { creator_name: CurrentUser.user.name }))
  end

  def add_post
    @favorite_group = authorize FavoriteGroup.find(params[:id])
    @post = Post.find(params[:post_id])
    @favorite_group.add(@post)

    respond_with(@favorite_group)
  end

  def remove_post
    @favorite_group = authorize FavoriteGroup.find(params[:id])
    @post = Post.find(params[:post_id])
    @favorite_group.remove(@post)

    respond_with(@favorite_group)
  end
end
