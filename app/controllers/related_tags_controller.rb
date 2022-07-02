# frozen_string_literal: true

class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    query = params[:query] || search_params[:query]
    category = params[:category] || search_params[:category]
    type = params[:type] || search_params[:type]
    limit = params[:limit]
    media_asset = MediaAsset.find(params[:media_asset_id]) if params[:media_asset_id].present?

    @query = RelatedTagQuery.new(query: query, media_asset: media_asset, category: category, type: type, user: CurrentUser.user, limit: limit)
    respond_with(@query)
  end
end
