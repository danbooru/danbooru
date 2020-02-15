class DtextLinksController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @dtext_links = DtextLink.paginated_search(params)
    @dtext_links = @dtext_links.includes(:model) if request.format.html?

    respond_with(@dtext_links)
  end
end
