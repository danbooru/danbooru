class MediaAssetsController < ApplicationController
  respond_to :json, :xml

  def index
    @media_assets = authorize MediaAsset.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@media_assets)
  end
end
