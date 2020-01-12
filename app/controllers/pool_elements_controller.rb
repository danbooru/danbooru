class PoolElementsController < ApplicationController
  respond_to :html, :xml, :json, :js
  before_action :member_only

  def create
    @pool = Pool.find_by_name(params[:pool_name]) || Pool.find_by_id(params[:pool_id])

    if @pool.present? && !@pool.is_deleted?
      @post = Post.find(params[:post_id])
      @pool.add!(@post)
    else
      @error = "That pool does not exist"
    end
  end
end
