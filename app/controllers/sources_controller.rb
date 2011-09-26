class SourcesController < ApplicationController
  # before_filter :member_only
  respond_to :json
  
  def show
    @source = Sources::Site.new(params[:url])
    respond_with(@source)
  end
end
