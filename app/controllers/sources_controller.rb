# frozen_string_literal: true

class SourcesController < ApplicationController
  respond_to :js, :json, :xml, :html

  rate_limit :show, rate: 20.0/1.minute, burst: 50

  def show
    @source = Source::Extractor.find(params[:url], params[:ref]) if params[:url].present?
    @mode = params[:mode] || "card"

    respond_with(@source.to_h) do |format|
      format.xml { render xml: @source.to_h.to_xml(root: "source") }
      format.json { render json: @source.to_h.to_json }
    end
  end
end
