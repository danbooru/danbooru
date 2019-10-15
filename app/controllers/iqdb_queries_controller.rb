class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml, :js

  def show
    # XXX allow bare search params for backwards compatibility.
    search_params.merge!(params.slice(:url, :post_id, :limit, :similarity).permit!)

    @matches = IqdbProxy.search(search_params)
    respond_with(@matches, template: "iqdb_queries/show")
  end

  alias create show
end
