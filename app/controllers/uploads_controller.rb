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

    case @mode
    when "table"
      @uploads = authorize Upload.visible(CurrentUser.user).paginated_search(params, count_pages: true)
      @uploads = @uploads.includes(:uploader, media_assets: [:post]) if request.format.html?
      respond_with(@uploads)
    when "gallery"
      @media_assets = authorize MediaAsset.distinct.visible(CurrentUser.user).joins(:uploads).where(uploads: { uploader: CurrentUser.user }).paginated_search(params, count_pages: true)
      respond_with(@media_assets)
    else
      raise "Invalid mode '#{mode}'"
    end
  end

  def show
    @upload = authorize Upload.find(params[:id])
    @post = Post.new(uploader: @upload.uploader, uploader_ip_addr: @upload.uploader_ip_addr, source: @upload.source, rating: nil, **permitted_attributes(Post))
    @post.tag_string = "#{@post.tag_string} #{@upload.source_strategy&.artists.to_a.map(&:tag).map(&:name).join(" ")}".strip

    if request.format.html? && @upload.is_completed? && @upload.media_assets.first&.post.present?
      flash[:notice] = "Duplicate of post ##{@upload.media_assets.first.post.id}"
      redirect_to @upload.media_assets.first.post
    else
      respond_with(@upload)
    end
  end
end
