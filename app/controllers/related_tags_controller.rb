class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    query = params[:query] || search_params[:query]
    category = params[:category] || search_params[:category]
    type = params[:type] || search_params[:type]
    limit = params[:limit]

    @query = RelatedTagQuery.new(query: query, category: category, type: type, user: CurrentUser.user, limit: limit)
    respond_with(@query)
  end
end
