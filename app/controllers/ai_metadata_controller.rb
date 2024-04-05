# frozen_string_literal: true

class AIMetadataController < ApplicationController
  respond_to :html, :json, :xml, :js

  def index
    @ai_metadata = authorize AIMetadata.paginated_search(params)
    @ai_metadata.includes(post: [:uploader, :media_asset]) if request.format.html?

    respond_with(@ai_metadata, model: "AIMetadata")
  end

  def show
    @ai_metadata = authorize AIMetadata.find(params[:id])
    respond_with(@ai_metadata) do |fmt|
      fmt.html { redirect_to ai_metadata_path(search: { id: @ai_metadata.id }) }
    end
  end

  def create_or_update
    post_id = params[:ai_metadata].delete(:post_id) || params[:post_id]
    @ai_metadata = authorize AIMetadata.find_or_initialize_by(post_id: post_id)
    prompt = params[:ai_metadata].delete(:prompt)
    negative_prompt = params[:ai_metadata].delete(:negative_prompt)
    parameters = params[:ai_metadata].permit!.to_h
    @ai_metadata.update(updater: CurrentUser.user, prompt:, negative_prompt:, parameters:)
    flash[:notice] = "AI metadata updated" if @ai_metadata.valid?
    respond_with(@ai_metadata, location: post_path(post_id))
  end

  def undo
    @ai_metadata = authorize AIMetadata.find_by_post_id!(params[:post_id])
    @version = @ai_metadata.versions.find(params[:version_id])
    @version.undo!(CurrentUser.user)
    respond_with(@ai_metadata)
  end

  def revert
    @ai_metadata = authorize AIMetadata.find_by_post_id!(params[:post_id])
    @version = @ai_metadata.versions.find(params[:version_id])
    @version.revert_to!(CurrentUser.user)
    respond_with(@ai_metadata)
  end
end
