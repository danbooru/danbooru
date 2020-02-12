class UploadsController < ApplicationController
  before_action :member_only, except: [:index, :show]
  respond_to :html, :xml, :json, :js
  skip_before_action :verify_authenticity_token, only: [:preprocess]

  def new
    @source = Sources::Strategies.find(params[:url], params[:ref]) if params[:url].present?
    @upload, @remote_size = UploadService::ControllerHelper.prepare(
      url: params[:url], ref: params[:ref]
    )
    respond_with(@upload)
  end

  def batch
    @url = params.dig(:batch, :url) || params[:url]
    @source = Sources::Strategies.find(@url, params[:ref]) if @url.present?
    respond_with(@source)
  end

  def image_proxy
    resp = ImageProxy.get_image(params[:url])
    send_data resp.body, :type => resp.content_type, :disposition => "inline"
  end

  def index
    @uploads = Upload.paginated_search(params, count_pages: true).includes(model_includes(params))
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

  def preprocess
    @upload, @remote_size = UploadService::ControllerHelper.prepare(
      url: upload_params[:source], file: upload_params[:file], ref: upload_params[:referer_url]
    )
    render body: nil
  end

  def create
    @service = UploadService.new(upload_params)
    @upload = @service.start!

    if @service.warnings.any?
      flash[:notice] = @service.warnings.join(".\n \n")
    end

    respond_with(@upload)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      [:uploader]
    else
      [:uploader, {post: [:uploader]}]
    end
  end

  def upload_params
    permitted_params = %i[
      file source tag_string rating status parent_id artist_commentary_title
      artist_commentary_desc include_artist_commentary referer_url
      md5_confirmation as_pending translated_commentary_title
      translated_commentary_desc
    ]

    params.require(:upload).permit(permitted_params)
  end
end
