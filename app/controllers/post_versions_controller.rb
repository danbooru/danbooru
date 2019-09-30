class PostVersionsController < ApplicationController
  before_action :member_only, except: [:index, :search]
  before_action :check_availabililty
  around_action :set_timeout
  respond_to :html, :xml, :json
  respond_to :js, only: [:undo]

  def index
    @post_versions = PostArchive.includes(:updater, post: [:versions]).search(search_params).paginate(params[:page], :limit => params[:limit], :search_count => params[:search])
    respond_with(@post_versions)
  end

  def search
  end

  def undo
    @post_version = PostArchive.find(params[:id])
    @post_version.undo!

    respond_with(@post_version)
  end

  private

  def set_timeout
    PostArchive.connection.execute("SET statement_timeout = #{CurrentUser.user.statement_timeout}")
    yield
  ensure
    PostArchive.connection.execute("SET statement_timeout = 0")
  end

  def check_availabililty
    if !PostArchive.enabled?
      raise NotImplementedError.new("Archive service is not configured. Post versions are not saved.")
    end
  end
end
