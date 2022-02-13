# frozen_string_literal: true

class UploadMediaAssetsController < ApplicationController
  respond_to :html, :xml, :json, :js

  def index
    @upload_media_assets = authorize UploadMediaAsset.visible(CurrentUser.user).includes(media_asset: :post, upload: :uploader).where(upload: { uploader: CurrentUser.user }).paginated_search(params, count_pages: true)
    respond_with(@upload_media_assets)
  end

  def show
    @upload_media_asset = authorize UploadMediaAsset.find(params[:id])
    @media_asset = @upload_media_asset.media_asset

    if request.format.html? && @media_asset&.post&.present?
      flash[:notice] = "Duplicate of post ##{@media_asset.post.id}"
      redirect_to @media_asset.post
    else
      respond_with(@upload_media_asset)
    end
  end
end
