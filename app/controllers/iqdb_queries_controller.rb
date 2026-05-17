# frozen_string_literal: true

class IqdbQueriesController < ApplicationController
  respond_to :html, :json, :xml, :js

  def show
    # XXX allow bare search params for backwards compatibility.
    search_params.merge!(params.slice(:url, :hash, :image_url, :file_url, :post_id, :media_asset_id, :limit, :similarity, :high_similarity).permit!)

    iqdb_params = search_params.to_h.symbolize_keys.without(:similarity, :high_similarity)
    @matches = authorize(IqdbClient.new).search(**iqdb_params)

    respond_with(@matches, template: "iqdb_queries/show", location: iqdb_queries_path)
  rescue IqdbClient::Error => e
    @matches = []
    respond_with(@matches, notice: e.message, template: "iqdb_queries/show", location: iqdb_queries_path)
  end

  alias_method :create, :show
end
