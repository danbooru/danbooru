class DtextLinksController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @dtext_links = DtextLink.includes(:model).paginated_search(params)
    respond_with(@dtext_links)
  end
end
