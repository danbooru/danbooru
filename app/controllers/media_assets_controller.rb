# frozen_string_literal: true

class MediaAssetsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @limit = params.fetch(:limit, CurrentUser.user.per_page).to_i.clamp(0, PostSets::Post::MAX_PER_PAGE)
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || MediaAssetGalleryComponent::DEFAULT_SIZE

    @media_assets = authorize MediaAsset.visible(CurrentUser.user).paginated_search(params, limit: @limit, count_pages: false)
    @media_assets = @media_assets.includes(:media_metadata, :post)
    respond_with(@media_assets)
  end

  def show
    @media_asset = authorize MediaAsset.find(params[:id])
    @post = Post.find_by_md5(@media_asset.md5)
    respond_with(@media_asset)
  end
end
