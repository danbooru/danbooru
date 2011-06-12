class PoolsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only, :except => [:index, :show]
  before_filter :moderator_only, :only => [:destroy]

  def new
    @pool = Pool.new
    respond_with(@pool)
  end
  
  def edit
    @pool = Pool.find(params[:id])
    respond_with(@pool)
  end
  
  def index
    @search = Pool.search(params[:search])
    @pools = @search.paginate(:page => params[:page])
    respond_with(@pools)
  end
  
  def search
    @search = Pool.search(params[:search])
  end
  
  def show
    @pool = Pool.find(params[:id])
    @post_set = PostSets::Base.new(:id => @pool, :page => params[:page])
    @post_set.extend(PostSets::Numbered)
    @post_set.extend(PostSets::Pool)
    respond_with(@pool)
  end
  
  def create
    @pool = Pool.create(params[:pool])
    respond_with(@pool)
  end
  
  def update
    @pool = Pool.find(params[:id])
    @pool.update_attributes(params[:pool])
    respond_with(@pool)
  end
  
  def destroy
    @pool = Pool.find(params[:id])
    @pool.destroy
    respond_with(@pool)
  end
  
  def revert
    @pool = Pool.find(params[:id])
    @version = PoolVersion.find(params[:version_id])
    @pool.revert_to!(@version)
    respond_with(@pool)
  end
end
