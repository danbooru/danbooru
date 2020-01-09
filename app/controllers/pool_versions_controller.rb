class PoolVersionsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :check_availabililty
  around_action :set_timeout

  def index
    if params[:search] && params[:search][:pool_id].present?
      @pool = Pool.find(params[:search][:pool_id])
    end

    @pool_versions = PoolArchive.paginated_search(params)
    respond_with(@pool_versions)
  end

  def search
  end

  def diff
    @pool_version = PoolArchive.find(params[:id])

    if params[:other_id]
      @other_version = PoolArchive.find(params[:other_id])
    else
      @other_version = @pool_version.previous
    end
  end

  private

  def set_timeout
    PoolArchive.connection.execute("SET statement_timeout = #{CurrentUser.user.statement_timeout}")
    yield
  ensure
    PoolArchive.connection.execute("SET statement_timeout = 0")
  end

  def check_availabililty
    if !PoolArchive.enabled?
      raise NotImplementedError.new("Archive service is not configured. Pool versions are not saved.")
    end
  end
end
