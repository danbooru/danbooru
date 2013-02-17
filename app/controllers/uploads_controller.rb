class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  
  def new
    @upload = Upload.new(:rating => "q")
    if params[:url]
      @post = Post.find_by_source(params[:url])
      @source = Sources::Site.new(params[:url])
    end
    respond_with(@upload)
  end
  
  def index
    @search = Upload.search(params[:search])
    @uploads = @search.order("id desc").paginate(params[:page])
    respond_with(@uploads)
  end
  
  def show
    @upload = Upload.find(params[:id])
    respond_with(@upload)
  end

  def create
    render :nothing => true
    return
    
  	@upload = Upload.create(params[:upload].merge(:server => Socket.gethostname))
  	@upload.delay.process!
    respond_with(@upload)
  end
  
  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end
end
