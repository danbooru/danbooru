class PoolsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  before_filter :moderator_only, :only => [:destroy]
  rescue_from User::PrivilegeError, :with => "static/access_denied"

  def new
    @pool = Pool.new
    respond_with(@pool)
  end
  
  def edit
    @pool = Pool.find(params[:id])
    respond_with(@pool)
  end
  
  def index
    @search = Pool.active.search(params[:search])
    @pools = @search.order("updated_at desc").paginate(params[:page])
    respond_with(@pools)
  end
  
  def search
  end
  
  def show
    @pool = Pool.find(params[:id])
    @post_set = PostSets::Pool.new(@pool, params[:page])
    respond_with(@pool)
  end
  
  def create
    @pool = Pool.create(params[:pool])
    respond_with(@pool, :notice => "Pool created")
  end
  
  def update
    # need to do this in order for synchronize! to work correctly
    @pool = Pool.find(params[:id])
    @pool.attributes = params[:pool]
    @pool.synchronize!
    @pool.save
    respond_with(@pool, :notice => "Pool updated")
  end
  
  def destroy
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, true)
    respond_with(@pool, :notice => "Pool deleted")
  end
  
  def undelete
    @pool = Pool.find(params[:id])
    if !@pool.deletable_by?(CurrentUser.user)
      raise User::PrivilegeError
    end
    @pool.update_attribute(:is_deleted, false)
    respond_with(@pool, :notice => "Pool undeleted")
  end
  
  def revert
    @pool = Pool.find(params[:id])
    @version = PoolVersion.find(params[:version_id])
    @pool.revert_to!(@version)
    respond_with(@pool, :notice => "Pool reverted")
  end
end
