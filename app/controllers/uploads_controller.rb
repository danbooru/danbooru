class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json, :js
  rescue_from Upload::Error, :with => :rescue_exception
  
  def new
    @upload = Upload.new(:rating => "q")
    if params[:url]
      @post = Post.find_by_source(params[:url])
      begin
        @source = Sources::Site.new(params[:url])
      rescue Exception
      end
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
    respond_with(@upload) do |format|
      format.html do
        if @upload.is_completed? && @upload.post_id
          redirect_to(post_path(@upload.post_id))
        end
      end
    end
  end

  def create
  	@upload = Upload.create(params[:upload].merge(:server => Socket.gethostname))
  	@upload.process!
    respond_with(@upload)
  end
  
  def update
    @upload = Upload.find(params[:id])
    @upload.process!
    respond_with(@upload)
  end
end
