class PoolVersionsController < ApplicationController
  def index
    @pool_versions = PoolVersion.search(params[:search]).order("updated_at desc").paginate(params[:page], :search_count => params[:search])
  end
end
