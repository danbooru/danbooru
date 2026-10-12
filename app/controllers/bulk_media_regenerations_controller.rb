# frozen_string_literal: true

class BulkMediaRegenerationsController < ApplicationController
  skip_before_action :normalize_search, only: [:new]

  def new
    @query = search_params[:ai_tags_match]
    authorize MediaAsset, :bulk_regenerate?

    if search_params.present? && @query.blank?
      @error = "You must enter a search query"
    elsif @query.present?
      @media_assets = MediaAsset.active.ai_tags_match(@query).order(id: :desc)
    end
  end

  def create
    @query = search_params[:ai_tags_match]
    authorize MediaAsset, :bulk_regenerate?

    if @query.blank?
      redirect_to new_bulk_media_regeneration_path, notice: "You must enter a search query"
      return
    end

    count = MediaAsset.active.ai_tags_match(@query).count
    ModAction.log(%{started a bulk regeneration of #{count} #{"media asset".pluralize(count)} matching "#{@query}"}, :media_asset_bulk_regenerate, subject: nil, user: CurrentUser.user)
    BulkMediaRegenerationJob.perform_later(query: @query)

    redirect_to new_bulk_media_regeneration_path(search: { ai_tags_match: @query }), notice: "Media asset regeneration scheduled for #{count} #{"asset".pluralize(count)}"
  end
end
