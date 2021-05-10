class PoolElementsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create
    @pool = Pool.find_by_name(params[:pool_name]) || Pool.find_by_id(params[:pool_id])
    raise ActiveRecord::RecordNotFound if @pool.nil?
    authorize(@pool, :update?)

    @post = Post.find(params[:post_id])
    @pool.add!(@post)
    respond_with(@pool)
  end
end
