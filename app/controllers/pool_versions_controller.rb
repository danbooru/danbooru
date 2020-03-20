class PoolVersionsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :check_availabililty
  around_action :set_timeout

  def index
    set_version_comparison
    @pool_versions = PoolVersion.paginated_search(params)
    @pool_versions = @pool_versions.includes(:updater, :pool) if request.format.html?

    respond_with(@pool_versions)
  end

  def search
  end

  def diff
    @pool_version = PoolVersion.find(params[:id])

    if params[:other_id]
      @other_version = PoolVersion.find(params[:other_id])
    else
      set_version_comparison
      @other_version = @pool_version.send(params[:type])
    end
  end

  private

  def set_timeout
    PoolVersion.connection.execute("SET statement_timeout = #{CurrentUser.user.statement_timeout}")
    yield
  ensure
    PoolVersion.connection.execute("SET statement_timeout = 0")
  end

  def check_availabililty
    if !PoolVersion.enabled?
      raise NotImplementedError.new("Archive service is not configured. Pool versions are not saved.")
    end
  end
end
