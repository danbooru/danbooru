class PoolsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def new
    @pool = authorize Pool.new(permitted_attributes(Pool))
    respond_with(@pool)
  end

  def edit
    @pool = authorize Pool.find(params[:id])
    respond_with(@pool)
  end

  def index
    @pools = authorize Pool.paginated_search(params, count_pages: true)

    respond_with(@pools)
  end

  def gallery
    limit = params[:limit].presence || CurrentUser.user.per_page
    search = search_params.presence || ActionController::Parameters.new(category: "series")

    @pools = authorize Pool.search(search).paginate(params[:page], limit: limit, search_count: params[:search])
    respond_with(@pools)
  end

  def show
    limit = params[:limit].presence || CurrentUser.user.per_page

    @pool = authorize Pool.find(params[:id])
    @posts = @pool.posts.paginate(params[:page], limit: limit, count: @pool.post_count)
    respond_with(@pool)
  end

  def create
    @pool = authorize Pool.new(permitted_attributes(Pool))
    @pool.save
    flash[:notice] = @pool.valid? ? "Pool created" : @pool.errors.full_messages.join("; ")
    respond_with(@pool)
  end

  def update
    # need to do this in order for synchronize! to work correctly
    @pool = authorize Pool.find(params[:id])
    @pool.attributes = permitted_attributes(@pool)
    @pool.synchronize
    @pool.save
    unless @pool.errors.any?
      flash[:notice] = "Pool updated"
    end
    respond_with(@pool)
  end

  def destroy
    @pool = authorize Pool.find(params[:id])
    @pool.update_attribute(:is_deleted, true)
    @pool.create_mod_action_for_delete
    flash[:notice] = "Pool deleted"
    respond_with(@pool)
  end

  def undelete
    @pool = authorize Pool.find(params[:id])
    @pool.update_attribute(:is_deleted, false)
    @pool.create_mod_action_for_undelete
    flash[:notice] = "Pool undeleted"
    respond_with(@pool)
  end

  def revert
    @pool = authorize Pool.find(params[:id])
    @version = @pool.versions.find(params[:version_id])
    @pool.revert_to!(@version)
    flash[:notice] = "Pool reverted"
    respond_with(@pool) do |format|
      format.js
    end
  end

  private

  def item_matches_params(pool)
    if params[:search][:name_matches]
      Pool.normalize_name_for_search(pool.name) == Pool.normalize_name_for_search(params[:search][:name_matches])
    else
      true
    end
  end
end
