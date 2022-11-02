# frozen_string_literal: true

class AIMetadataController < ApplicationController
  respond_to :html, :json, :xml, :js

  def index
    @ai_metadata = authorize AIMetadata.paginated_search(params)
    @ai_metadata.includes(post: [:uploader, :media_asset]) if request.format.html?

    respond_with(@ai_metadata)
  end

  def search
  end

  def show
    @ai_metadata = authorize AIMetadata.find(params[:id])
    respond_with(@ai_metadata)
  end

  def create_or_update
    post_id = params[:ai_metadata].delete(:post_id) || params[:post_id]
    @ai_metadata = authorize AIMetadata.find_or_initialize_by(post_id: post_id)
    @ai_metadata.update(updater: CurrentUser.user, **permitted_attributes(@ai_metadata))
    flash[:notice] = "AI metadata updated" if @ai_metadata.valid?
    respond_with(@ai_metadata)
  end

  def revert
    @ai_metadata = authorize AIMetadata.find_by_post_id!(params[:id])
    @version = @ai_metadata.versions.find(params[:version_id])
    @ai_metadata.revert_to!(@version)
    respond_with(@ai_metadata)
  end
end
