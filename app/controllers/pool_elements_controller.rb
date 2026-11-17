# frozen_string_literal: true

class PoolElementsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def create
    @pool = params[:pool_name].present? ? Pool.find_by_name(params.expect(:pool_name)) : Pool.find_by_id(params.expect(:pool_id))
    raise ActiveRecord::RecordNotFound if @pool.nil?
    authorize(@pool, :update?)

    @post = Post.find(params.expect(:post_id))
    @pool.add!(@post)
    respond_with(@pool)
  end
end
