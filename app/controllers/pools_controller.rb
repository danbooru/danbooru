# frozen_string_literal: true

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
    if request.format.html?
      @pools = authorize Pool.paginated_search(params, count_pages: true, defaults: { is_deleted: false })
    else
      @pools = authorize Pool.paginated_search(params, count_pages: true)
    end

    respond_with(@pools)
  end

  def gallery
    limit = params[:limit].presence || CurrentUser.user.per_page
    search = search_params.presence || ActionController::Parameters.new(category: "series")

    @pools = authorize Pool.search(search, CurrentUser.user).paginate(params[:page], limit: limit, search_count: params[:search])
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

    respond_with(@pool, notice: "Pool created")
  end

  def update
    @pool = authorize Pool.find(params[:id])
    @pool.update(permitted_attributes(@pool))

    respond_with(@pool, notice: "Pool updated")
  end

  def destroy
    @pool = authorize Pool.find(params[:id])
    @pool.update(is_deleted: true)
    @pool.create_mod_action_for_delete

    respond_with(@pool, notice: "Pool deleted")
  end

  def undelete
    @pool = authorize Pool.find(params[:id])
    @pool.update(is_deleted: false)
    @pool.create_mod_action_for_undelete

    respond_with(@pool, notice: "Pool undeleted")
  end

  def revert
    @pool = authorize Pool.find(params[:id])
    @version = @pool.versions.find(params[:version_id])
    @pool.revert_to!(@version)

    respond_with(@pool, notice: "Pool reverted") do |format|
      format.js
    end
  end

  private

  def item_matches_params(pool)
    if params[:search][:name_contains]
      Pool.normalize_name_for_search(pool.name) == Pool.normalize_name_for_search(params[:search][:name_contains])
    else
      true
    end
  end
end
