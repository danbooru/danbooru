# frozen_string_literal: true

class MediaAssetsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @media_assets = authorize MediaAsset.visible(CurrentUser.user).paginated_search(params, count_pages: false)
    @media_assets = @media_assets.includes(:media_metadata, :post)
    respond_with(@media_assets)
  end

  def show
    @media_asset = authorize MediaAsset.find(params[:id])
    @post = Post.find_by_md5(@media_asset.md5)
    respond_with(@media_asset)
  end
end
