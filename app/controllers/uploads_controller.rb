class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  
  def new
    @upload = Upload.new(:rating => "q")
    if params[:url]
      @post = Post.find_by_source(params[:url])
    end
    respond_with(@upload)
  end
  
  def index
    @search = Upload.search(params[:search])
    @uploads = @search.paginate(:page => params[:page])
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
