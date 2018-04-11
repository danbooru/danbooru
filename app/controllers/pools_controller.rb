class PoolsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only, :except => [:index, :show, :gallery]
  before_action :builder_only, :only => [:destroy]

  def new
    @pool = Pool.new
    respond_with(@pool)
  end

  def edit
    @pool = Pool.find(params[:id])
    if @pool.is_deleted && !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    respond_with(@pool)
  end

  def index
    @pools = Pool.search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@pools) do |format|
      format.xml do
        render :xml => @pools.to_xml(:root => "pools")
      end
    end
  end

  def gallery
    limit = params[:limit] || CurrentUser.user.per_page
    @pools = Pool.series.search(search_params).reorder("updated_at desc").paginate(params[:page], :limit => limit, :search_count => params[:search])
    @post_set = PostSets::PoolGallery.new(@pools)
  end

  def show
    @pool = Pool.find(params[:id])
    @post_set = PostSets::Pool.new(@pool, params[:page])
    respond_with(@pool)
  end

  def create
    @pool = Pool.create(pool_params)
    flash[:notice] = @pool.valid? ? "Pool created" : @pool.errors.full_messages.join("; ")
    respond_with(@pool)
  end

  def update
    # need to do this in order for synchronize! to work correctly
    @pool = Pool.find(params[:id])
    @pool.attributes = pool_params
    @pool.synchronize
    @pool.save
    unless @pool.errors.any?
      flash[:notice] = "Pool updated"
    end
    respond_with(@pool)
  end

  def destroy
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, true)
    @pool.create_mod_action_for_delete
    flash[:notice] = "Pool deleted"
    respond_with(@pool)
  end

  def undelete
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, false)
    @pool.create_mod_action_for_undelete
    flash[:notice] = "Pool undeleted"
    respond_with(@pool)
  end

  def revert
    @pool = Pool.find(params[:id])
    @version = @pool.versions.find(params[:version_id])
    @pool.revert_to!(@version)
    flash[:notice] = "Pool reverted"
    respond_with(@pool) do |format|
      format.js
    end
  end

  private

  def pool_params
    permitted_params = %i[name description category is_active post_ids]
    params.require(:pool).permit(permitted_params)
  end
end
