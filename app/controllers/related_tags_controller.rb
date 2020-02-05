class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    query = params[:query] || search_params[:query]
    category = params[:category] || search_params[:category]

    @query = RelatedTagQuery.new(query: query, category: category, user: CurrentUser.user)
    respond_with(@query)
  end
end
