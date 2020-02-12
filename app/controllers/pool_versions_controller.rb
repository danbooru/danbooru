class PoolVersionsController < ApplicationController
  respond_to :html, :xml, :json
  before_action :check_availabililty
  around_action :set_timeout

  def index
    @pool_versions = PoolArchive.paginated_search(params).includes(model_includes(params))
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

  def model_name
    "PoolArchive"
  end

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:updater, :pool]
    end
  end

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
