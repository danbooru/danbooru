# frozen_string_literal: true

class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    # XXX allow bare search params for backwards compatibility.
    search_params.merge!(params.slice(:query, :category, :search_sample_size, :tag_sample_size, :order).permit!)

    query = search_params[:query]
    categories = search_params[:category] || search_params[:categories]
    order = search_params[:order]
    search_sample_size = search_params[:search_sample_size]
    tag_sample_size = search_params[:tag_sample_size]
    limit = params[:limit]
    media_asset = MediaAsset.find(params[:media_asset_id]) if params[:media_asset_id].present?

    @query = RelatedTagQuery.new(query:, media_asset:, categories:, search_sample_size:, tag_sample_size:, order:, limit:, user: CurrentUser.user)
    authorize @query

    expires_in @query.cache_duration, public: @query.cache_publicly? if request.format.js? && response.cache_control.blank? && params[:user_tags].blank?
    respond_with(@query)
  end
end
