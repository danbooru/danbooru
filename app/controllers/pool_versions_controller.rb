class PoolVersionsController < ApplicationController
  def index
    @search = PoolVersion.search(params[:search])
    @pool_versions = @search.order("id desc").paginate(params[:page])
  end
end
