class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json
  
  def new
    @upload = Upload.new(:rating => "q")
    if params[:url]
      @post = Post.find_by_source(params[:url])
    end
    respond_with(@upload)
  end
  
  def index
    @uploads = Upload.where("uploader_id = ?", CurrentUser.user.id).includes(:uploader).order("uploads.id desc").limit(10)
    respond_with(@uploads)
  end
  
  def show
    @upload = Upload.find(params[:id])
    respond_with(@upload)
  end

  def create
  	@upload = Upload.create(params[:upload])
    respond_with(@upload)
  end
  
  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end
end
