class PoolOrdersController < ApplicationController
  respond_to :html, :xml, :json, :js

  def edit
    @pool = authorize Pool.find(params[:pool_id])
    respond_with(@pool)
  end
end
