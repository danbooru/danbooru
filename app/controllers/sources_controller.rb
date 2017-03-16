class SourcesController < ApplicationController
  respond_to :json, :xml

  def show
    @source = Sources::Site.new(params[:url], :referer_url => params[:ref])
    @source.get

    respond_with(@source.to_h) do |format|
      format.xml { render xml: @source.to_h.to_xml(root: "source") }
    end
  end
end
