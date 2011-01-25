class PoolVersionsController < ApplicationController
  def index
    @search = PoolVersion.search(params[:search])
    @pool_versions = @search.paginate(:page => params[:page])
  end
end
