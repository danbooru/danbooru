class UploadsController < ApplicationController
  respond_to :html, :xml, :json, :js
  skip_before_action :verify_authenticity_token, only: [:preprocess]

  def new
    authorize Upload
    @source = Sources::Strategies.find(params[:url], params[:ref]) if params[:url].present?
    @upload, @remote_size = UploadService::ControllerHelper.prepare(
      url: params[:url], ref: params[:ref]
    )
    respond_with(@upload)
  end

  def batch
    authorize Upload
    @url = params.dig(:batch, :url) || params[:url]
    @source = Sources::Strategies.find(@url, params[:ref]) if @url.present?
    respond_with(@source)
  end

  def image_proxy
    authorize Upload
    resp = ImageProxy.get_image(params[:url])
    send_data resp.body, type: resp.mime_type, disposition: "inline"
  end

  def index
    @uploads = authorize Upload.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @uploads = @uploads.includes(:uploader, post: :uploader) if request.format.html?

    respond_with(@uploads)
  end

  def show
    @upload = authorize Upload.find(params[:id])
    respond_with(@upload) do |format|
      format.html do
        if @upload.is_completed? && @upload.post_id
          redirect_to(post_path(@upload.post_id))
        end
      end
    end
  end

  def preprocess
    authorize Upload
    @upload, @remote_size = UploadService::ControllerHelper.prepare(
      url: params.dig(:upload, :source), file: params.dig(:upload, :file), ref: params.dig(:upload, :referer_url),
    )
    render body: nil
  end

  def create
    @service = authorize UploadService.new(permitted_attributes(Upload)), policy_class: UploadPolicy
    @upload = @service.start!

    if @service.warnings.any?
      flash[:notice] = @service.warnings.join(".\n \n")
    end

    respond_with(@upload)
  end
end
