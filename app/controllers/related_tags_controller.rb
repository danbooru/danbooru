class RelatedTagsController < ApplicationController
  respond_to :json, :xml, :js, :html

  def show
    @query = RelatedTagQuery.new(query: params[:query], category: params[:category], user: CurrentUser.user)
    respond_with(@query)
  end
end
