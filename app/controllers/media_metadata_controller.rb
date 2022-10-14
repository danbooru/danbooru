# frozen_string_literal: true

class MediaMetadataController < ApplicationController
  respond_to :json, :xml

  def index
    @media_metadata = authorize MediaMetadata.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    respond_with(@media_metadata, model: "MediaMetadata")
  end
end
