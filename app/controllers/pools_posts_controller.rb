class PoolsPostsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_filter :member_only
  
  def create
    @pool = Pool.find_by_name(params[:pool_name]) || Pool.find(params[:pool_id])
    @post = Post.find(params[:post_id])
    @pool.add_post!(@post)
    append_pool_to_session(@pool)
    respond_with(@pool, :location => pool_path(@pool))
  end
  
  def destroy
    @pool = Pool.find(params[:pool_id])
    @post = Post.find(params[:post_id])
    @pool.remove_post!(@post)
    respond_with(@pool, :location => pool_path(@pool))
  end
  
private
  def append_pool_to_session(pool)
    recent_pool_ids = session[:recent_pool_ids].to_s.scan(/\d+/)
    recent_pool_ids << pool.id.to_s
    recent_pool_ids = recent_pool_ids.slice(1, 5) if recent_pool_ids.size > 5
    session[:recent_pool_ids] = recent_pool_ids.uniq.join(",")
  end
end
