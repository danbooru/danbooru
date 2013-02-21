class PoolVersionsController < ApplicationController
  def index
    @search = PoolVersion.search(params[:search])
    @pool_versions = @search.order("updated_at desc").paginate(params[:page])
  end
end
