# frozen_string_literal: true

class UploadsController < ApplicationController
  respond_to :html, :xml, :json, :js
  skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.xhr? }

  def new
    @upload = authorize Upload.new(uploader: CurrentUser.user, uploader_ip_addr: CurrentUser.ip_addr, rating: "q", tag_string: "", source: params[:url], referer_url: params[:ref], **permitted_attributes(Upload))
    respond_with(@upload)
  end

  def create
    @upload = authorize Upload.new(uploader: CurrentUser.user, uploader_ip_addr: CurrentUser.ip_addr, rating: "q", tag_string: "", **permitted_attributes(Upload))
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
    @uploads = authorize Upload.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @uploads = @uploads.includes(:uploader, :media_assets) if request.format.html?

    respond_with(@uploads)
  end

  def show
    @upload = authorize Upload.find(params[:id])
    @post = Post.new(uploader: @upload.uploader, uploader_ip_addr: @upload.uploader_ip_addr, source: @upload.source, rating: nil, **permitted_attributes(Post))

    if request.format.html? && @upload.is_completed? && @upload.media_assets.first&.post.present?
      flash[:notice] = "Duplicate of post ##{@upload.media_assets.first.post.id}"
      redirect_to @upload.media_assets.first.post
    else
      respond_with(@upload)
    end
  end
end
