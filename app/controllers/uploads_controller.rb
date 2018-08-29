class UploadsController < ApplicationController
  before_action :member_only, except: [:index, :show]
  respond_to :html, :xml, :json, :js
  skip_before_action :verify_authenticity_token, only: [:preprocess]

  def new
    @upload_notice_wiki = WikiPage.titled(Danbooru.config.upload_notice_wiki_page).first
    @upload, @post, @source, @remote_size = UploadService::ControllerHelper.prepare(
      url: params[:url], ref: params[:ref]
    )
    respond_with(@upload)
  end

  def batch
    @url = params.dig(:batch, :url) || params[:url]
    @source = UploadService::ControllerHelper.batch(@url, params[:ref])
    respond_with(@source)
  end

  def image_proxy
    resp = ImageProxy.get_image(params[:url])
    send_data resp.body, :type => resp.content_type, :disposition => "inline"
  end

  def index
    @uploads = Upload.search(search_params).includes(:post, :uploader).paginate(params[:page], :limit => params[:limit])
    respond_with(@uploads) do |format|
      format.xml do
        render :xml => @uploads.to_xml(:root => "uploads")
      end
    end
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
    @upload, @post, @source, @remote_size = UploadService::ControllerHelper.prepare(
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

    save_recent_tags
    respond_with(@upload)
  end

  private

  def save_recent_tags
    if @upload
      tags = Tag.scan_tags(@upload.tag_string)
      tags = (TagAlias.to_aliased(tags) + Tag.scan_tags(cookies[:recent_tags])).compact.uniq.slice(0, 30)
      cookies[:recent_tags] = tags.join(" ")
      cookies[:recent_tags_with_categories] = Tag.categories_for(tags).to_a.flatten.join(" ")
    end
  end

  def upload_params
    permitted_params = %i[
      file source tag_string rating status parent_id artist_commentary_title
      artist_commentary_desc include_artist_commentary referer_url
      md5_confirmation as_pending
    ]

    params.require(:upload).permit(permitted_params)
  end
end
