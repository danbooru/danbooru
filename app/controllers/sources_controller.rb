class SourcesController < ApplicationController
  respond_to :json, :xml
  rescue_from Sources::Site::NoStrategyError, :with => :no_strategy

  def show
    @source = Sources::Site.new(params[:url], :referer_url => params[:ref])
    @source.get

    respond_with(@source.to_h) do |format|
      format.xml { render xml: @source.to_h.to_xml(root: "source") }
      format.json { render json: @source.to_h.to_json }
    end
  end

protected

  def no_strategy
    render json: {message: "Unsupported site"}.to_json, status: 400
  end
end
