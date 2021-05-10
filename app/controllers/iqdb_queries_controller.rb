class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml, :js

  def show
    # XXX allow bare search params for backwards compatibility.
    search_params.merge!(params.slice(:url, :image_url, :file_url, :post_id, :limit, :similarity, :high_similarity).permit!)

    @high_similarity_matches, @low_similarity_matches, @matches = IqdbProxy.new.search(search_params)
    respond_with(@matches, template: "iqdb_queries/show")
  end

  alias create show
end
