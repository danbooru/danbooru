# frozen_string_literal: true

class AITagsController < ApplicationController
  respond_to :js, :html, :json, :xml

  def index
    @ai_tags = authorize AITag.visible(CurrentUser.user).paginated_search(params, count_pages: false)
    @ai_tags = @ai_tags.includes(:media_asset, :tag, :post) if request.format.html?

    @mode = params.fetch(:mode, "gallery")
    @preview_size = params[:size].presence || cookies[:post_preview_size].presence || MediaAssetGalleryComponent::DEFAULT_SIZE

    respond_with(@ai_tags)
  end
end
