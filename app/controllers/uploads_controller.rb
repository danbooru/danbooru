# frozen_string_literal: true

class UploadsController < ApplicationController
  respond_to :html, :xml, :json, :js
  skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.xhr? }

  def new
    @upload = authorize Upload.new(uploader: CurrentUser.user, uploader_ip_addr: CurrentUser.ip_addr, source: params[:url], referer_url: params[:ref], **permitted_attributes(Upload))
    respond_with(@upload)
  end

  def create
    @upload = authorize Upload.new(uploader: CurrentUser.user, uploader_ip_addr: CurrentUser.ip_addr, **permitted_attributes(Upload))
    @upload.save
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
    @mode = params.fetch(:mode, "table")
    @defaults = { defaults: { status: "completed" }} if request.format.html?
    @uploads = authorize Upload.visible(CurrentUser.user).paginated_search(params, count_pages: true, **@defaults.to_h)
    @uploads = @uploads.includes(:uploader, media_assets: :post, upload_media_assets: { media_asset: :post }) if request.format.html?

    respond_with(@uploads, include: { upload_media_assets: { include: :media_asset }})
  end

  def show
    @upload = authorize Upload.find(params[:id])

    if request.format.html? && @upload.media_asset_count == 1 && @upload.media_assets.first&.post.present?
      flash[:notice] = "Duplicate of post ##{@upload.media_assets.first.post.id}"
      redirect_to @upload.media_assets.first.post
    else
      respond_with(@upload, include: { upload_media_assets: { include: :media_asset }})
    end
  end
end
