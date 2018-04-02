class PoolElementsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only

  def create
    @pool = Pool.find_by_name(params[:pool_name]) || Pool.find_by_id(params[:pool_id])

    if @pool.present? && !@pool.is_deleted?
      @post = Post.find(params[:post_id])
      @pool.add!(@post)
      append_pool_to_session(@pool)
    else
      @error = "That pool does not exist"
    end
  end

  def destroy
    @pool = Pool.find(params[:pool_id])
    @post = Post.find(params[:post_id])
    @pool.remove!(@post)
    respond_with(@pool, :location => post_path(@post))
  end

  def all_select
    @pools = Pool.undeleted.where("is_active = true").order("name").select("id, name")
    @pools.each # hack to force rails to eager load
    @pools
  end

private
  def append_pool_to_session(pool)
    recent_pool_ids = session[:recent_pool_ids].to_s.scan(/\d+/)
    recent_pool_ids << pool.id.to_s
    recent_pool_ids = recent_pool_ids.slice(1, 5) if recent_pool_ids.size > 5
    session[:recent_pool_ids] = recent_pool_ids.uniq.join(",")
  end
end
