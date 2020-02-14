class FavoriteGroupsController < ApplicationController
  before_action :member_only, :except => [:index, :show]
  respond_to :html, :xml, :json, :js

  def index
    params[:search][:creator_id] ||= params[:user_id]
    @favorite_groups = FavoriteGroup.paginated_search(params).includes(model_includes(params))
    respond_with(@favorite_groups)
  end

  def show
    limit = params[:limit].presence || CurrentUser.user.per_page

    @favorite_group = FavoriteGroup.find(params[:id])
    check_read_privilege(@favorite_group)
    @posts = @favorite_group.posts.paginate(params[:page], limit: limit, count: @favorite_group.post_count)

    respond_with(@favorite_group)
  end

  def new
    @favorite_group = FavoriteGroup.new
    respond_with(@favorite_group)
  end

  def create
    @favorite_group = CurrentUser.favorite_groups.create(favgroup_params)
    respond_with(@favorite_group)
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
    @favorite_group.destroy!
    flash[:notice] = "Favorite group deleted" if request.format.html?
    respond_with(@favorite_group, location: favorite_groups_path(search: { creator_name: CurrentUser.name }))
  end

  def add_post
    @favorite_group = FavoriteGroup.find(params[:id])
    check_write_privilege(@favorite_group)
    @post = Post.find(params[:post_id])
    @favorite_group.add!(@post)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:creator]
    end
  end

  def check_write_privilege(favgroup)
    raise User::PrivilegeError unless favgroup.editable_by?(CurrentUser.user)
  end

  def check_read_privilege(favgroup)
    raise User::PrivilegeError unless favgroup.viewable_by?(CurrentUser.user)
  end

  def favgroup_params
    params.fetch(:favorite_group, {}).permit(%i[name post_ids post_ids_string is_public], post_ids: [])
  end
end
