class PoolsPostsController < ApplicationController
  respond_to :html, :xml, :json
  before_filter :member_only
  
  def create
    @pool = Pool.find(params[:pool_id])
    @post = Post.find(params[:id])
    @pool.add_post!(@post)
    respond_with(@pool, :location => pool_path(@pool))
  end
  
  def destroy
    @pool = Pool.find(params[:pool_id])
    @post = Post.find(params[:id])
    @pool.remove_post!(@post)
    respond_with(@pool, :location => pool_path(@pool))
  end
end
