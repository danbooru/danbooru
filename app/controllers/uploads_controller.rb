class UploadsController < ApplicationController
  before_filter :member_only
  respond_to :html, :xml, :json
  
  def new
    @upload = Upload.new(:rating => "q")
    if params[:url]
      @post = Post.find_by_source(params[:url])
    end
  end
  
  def show
    @upload = Upload.find(params[:id])
  end

  def create
  	@upload = Upload.create(params[:upload].merge(:uploader_id => @current_user.id, :uploader_ip_addr => request.remote_ip))
    respond_with(@upload)
  end
end
