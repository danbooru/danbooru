class PoolVersionsController < ApplicationController
  def index
    if params[:search] && params[:search][:pool_id]
      @pool = Pool.find(params[:search][:pool_id])
    end

    @pool_versions = PoolVersion.search(params[:search]).order("updated_at desc").paginate(params[:page], :search_count => params[:search])
  end
end
