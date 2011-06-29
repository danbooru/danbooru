class PoolVersionsController < ApplicationController
  def index
    @search = PoolVersion.search(params[:search])
    @pool_versions = @search.paginate(params[:page])
  end
end
