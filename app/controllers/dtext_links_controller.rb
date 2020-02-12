class DtextLinksController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @dtext_links = DtextLink.paginated_search(params).includes(model_includes(params))
    respond_with(@dtext_links)
  end

  private

  def default_includes(params)
    if ["json", "xml"].include?(params[:format])
      []
    else
      [:model]
    end
  end
end
