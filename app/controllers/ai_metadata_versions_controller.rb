# frozen_string_literal: true

class AIMetadataVersionsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @ai_metadata_versions = AIMetadataVersion.paginated_search(params)
    @ai_metadata_versions.includes(:updater, post: [:uploader, :media_asset]) if request.format.html?

    respond_with(@ai_metadata_versions)
  end

  def show
    @ai_metadata_version = AIMetadataVersion.find(params[:id])

    respond_with(@ai_metadata_version) do |fmt|
      fmt.html { redirect_to ai_metadata_versions_path(search: { post_id: @ai_metadata_version.post_id })}
    end
  end
end
