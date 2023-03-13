# frozen_string_literal: true

class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    # XXX allow bare search params for backwards compatibility.
    search_params.merge!(params.slice(:query, :category, :type).permit!)

    query = search_params[:query]
    categories = search_params[:category] || search_params[:categories]
    type = search_params[:type]
    limit = params[:limit]
    media_asset = MediaAsset.find(params[:media_asset_id]) if params[:media_asset_id].present?

    @query = RelatedTagQuery.new(query: query, media_asset: media_asset, categories: categories, type: type, user: CurrentUser.user, limit: limit)
    respond_with(@query)
  end
end
