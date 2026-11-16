# frozen_string_literal: true

class UploadMediaAssetsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @defaults = { upload_id: params[:upload_id] }
    @defaults[:order] = "id_asc" if params[:upload_id].present?
    @limit = params.fetch(:limit, 200).to_i.clamp(0, PostSets::Post::MAX_PER_PAGE)

    @upload_media_assets = authorize UploadMediaAsset.visible(CurrentUser.user).paginated_search(params, limit: @limit, count_pages: true, defaults: @defaults)
    @upload_media_assets = @upload_media_assets.includes(:post, :media_asset, upload: :uploader) if request.format.html? || request.format.js?

    if request.format.html? && params[:upload_id].present?
      @upload = Upload.find(params[:upload_id])
    end

    respond_with(@upload_media_assets)
  end

  def show
    @upload_media_asset = authorize UploadMediaAsset.find(params[:id])
    @media_asset = @upload_media_asset.media_asset

    if request.format.html? && @media_asset&.post.present?
      flash[:notice] = "Duplicate of post ##{@media_asset.post.id}"
      redirect_to @media_asset.post
    elsif request.format.html?
      @post = Post.new_from_upload(@upload_media_asset, add_artist_tag: true, source: @upload_media_asset.canonical_url, **permitted_attributes(Post).to_h.symbolize_keys)
      respond_with(@upload_media_asset)
    else
      respond_with(@upload_media_asset)
    end
  end
end
