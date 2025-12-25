# frozen_string_literal: true

class MediaAssetsController < ApplicationController
  respond_to :html, :json, :xml, :js

  def index
    @limit = params.fetch(:limit, CurrentUser.user.per_page).to_i.clamp(0, PostSets::Post::MAX_PER_PAGE)
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || MediaAssetGalleryComponent::DEFAULT_SIZE

    @media_assets = authorize MediaAsset.visible(CurrentUser.user).paginated_search(params, limit: @limit, count_pages: false)
    @media_assets = @media_assets.includes(:media_metadata, :post)
    respond_with(@media_assets)
  end

  def show
    @media_asset = authorize MediaAsset.includes(uploads: :uploader).find(params[:id])
    @post = Post.find_by_md5(@media_asset.md5)

    if CurrentUser.is_owner? && request.format.symbol.in?(%i[jpeg webp avif])
      width = params.fetch(:width, @media_asset.image_width).to_i
      height = params.fetch(:height, @media_asset.image_height).to_i
      quality = params.fetch(:quality, 85).to_i
      original_file = @media_asset.variant(:original).open_file

      if width != @media_asset.image_width || height != @media_asset.image_height || request.format != @media_asset.mime_type
        media_file = original_file.preview!(width, height, format: request.format.symbol, quality: quality)
      else
        media_file = original_file
      end

      send_file(media_file.path, type: media_file.mime_type, disposition: "inline")
    else
      respond_with(@media_asset)
    end
  end

  def destroy
    @media_asset = authorize MediaAsset.find(params[:id])
    @media_asset.trash!(CurrentUser.user)

    respond_with(@media_asset, notice: "File deleted")
  end

  def image
    media_asset = authorize MediaAsset.find(params[:media_asset_id])
    variant = media_asset.variant(params[:variant])
    raise ActiveRecord::RecordNotFound if variant.nil?

    redirect_to variant.file_url, allow_other_host: true
  end
end
