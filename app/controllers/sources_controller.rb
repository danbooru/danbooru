# frozen_string_literal: true

class SourcesController < ApplicationController
  respond_to :js, :json, :xml, :html

  def show
    @source = Source::Extractor.find(params[:url], params[:ref]) if params[:url].present?
    @mode = params[:mode] || "card"
    authorize @source, policy_class: SourcePolicy

    respond_with(@source.to_h) do |format|
      format.xml { render xml: @source.to_h.to_xml(root: "source") }
      format.json { render json: @source.to_h.to_json }
    end
  end
end
