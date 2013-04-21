class PoolVersionsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    if params[:search] && params[:search][:pool_id].present?
      @pool = Pool.find(params[:search][:pool_id])
    end

    @pool_versions = PoolVersion.search(params[:search]).order("updated_at desc").paginate(params[:page], :search_count => params[:search])
    respond_with(@pool_versions) do |format|
      format.xml do
        render :xml => @pool_versions.to_xml(:root => "pool-versions")
      end
    end
  end
end
