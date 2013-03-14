class RelatedTagsController < ApplicationController
  respond_to :json
  
  def show
    @query = RelatedTagQuery.new(params[:query].to_s.downcase, params[:category])
    respond_with(@query) do |format|
      format.json do
        render :json => @query.to_json
      end
    end
  end
end
