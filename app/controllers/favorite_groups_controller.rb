class FavoriteGroupsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def index
    @favorite_groups = FavoriteGroup.search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@favorite_groups) do |format|
      format.xml do
        render :xml => @favorite_groups.to_xml(:root => "favorite-groups")
      end
    end
  end

  def show
    @favorite_group = FavoriteGroup.find(params[:id])
    check_read_privilege(@favorite_group)
    @post_set = PostSets::FavoriteGroup.new(@favorite_group, params[:page])
    respond_with(@favorite_group)
  end

  def new
    @favorite_group = FavoriteGroup.new
    respond_with(@favorite_group)
  end

  def create
    @favorite_group = FavoriteGroup.create(favgroup_params)
    respond_with(@favorite_group) do |format|
      format.html do
        if @favorite_group.errors.any?
          render :action => "new"
        else
          redirect_to favorite_groups_path
        end
      end
    end
  end

  def edit
    @favorite_group = FavoriteGroup.find(params[:id])
    check_write_privilege(@favorite_group)
    respond_with(@favorite_group)
  end

  def update
    @favorite_group = FavoriteGroup.find(params[:id])
    check_write_privilege(@favorite_group)
    @favorite_group.update(favgroup_params)
    unless @favorite_group.errors.any?
      flash[:notice] = "Favorite group updated"
    end
    respond_with(@favorite_group)
  end

  def destroy
    @favorite_group = FavoriteGroup.find(params[:id])
    check_write_privilege(@favorite_group)
    @favorite_group.destroy
    flash[:notice] = "Favorite group deleted"
    redirect_to favorite_groups_path
  end

  def add_post
    @favorite_group = FavoriteGroup.find(params[:id])
    check_write_privilege(@favorite_group)
    @post = Post.find(params[:post_id])
    @favorite_group.add!(@post.id)
  end

  private

  def check_write_privilege(favgroup)
    raise User::PrivilegeError unless favgroup.editable_by?(CurrentUser.user)
  end

  def check_read_privilege(favgroup)
    raise User::PrivilegeError unless favgroup.viewable_by?(CurrentUser.user)
  end

  def favgroup_params
    params.fetch(:favorite_group, {}).permit(%i[name post_ids is_public])
  end
end
