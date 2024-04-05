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

    @pools = authorize Pool.search(search_params, CurrentUser.user).paginate(params[:page], limit: limit, search_count: params[:search])
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
    @pool = authorize Pool.find(params[:id])
    @pool.update(permitted_attributes(@pool))
    unless @pool.errors.any?
      flash[:notice] = "Pool updated"
    end
    respond_with(@pool)
  end

  def destroy
    @pool = authorize Pool.find(params[:id])
    @pool.update(is_deleted: true)
    @pool.create_mod_action_for_delete
    flash[:notice] = "Pool deleted"
    respond_with(@pool)
  end

  def undelete
    @pool = authorize Pool.find(params[:id])
    @pool.update(is_deleted: false)
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
    if params[:search][:name_contains]
      Pool.normalize_name_for_search(pool.name) == Pool.normalize_name_for_search(params[:search][:name_contains])
    else
      true
    end
  end
end
