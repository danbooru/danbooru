class PostVersionsController < ApplicationController
  before_action :member_only, except: [:index, :search]
  before_action :check_availabililty
  around_action :set_timeout
  respond_to :html, :xml, :json
  respond_to :js, only: [:undo]

  def index
    set_version_comparison
    @post_versions = PostVersion.paginated_search(params)

    if request.format.html?
      @post_versions = @post_versions.includes(:updater, post: [:uploader, :versions])
    else
      @post_versions = @post_versions.includes(post: :versions)
    end

    respond_with(@post_versions)
  end

  def search
  end

  def undo
    @post_version = PostVersion.find(params[:id])
    @post_version.undo!

    respond_with(@post_version)
  end

  private

  def set_timeout
    PostVersion.connection.execute("SET statement_timeout = #{CurrentUser.user.statement_timeout}")
    yield
  ensure
    PostVersion.connection.execute("SET statement_timeout = 0")
  end

  def check_availabililty
    if !PostVersion.enabled?
      raise NotImplementedError.new("Archive service is not configured. Post versions are not saved.")
    end
  end
end
