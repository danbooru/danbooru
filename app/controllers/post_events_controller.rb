class PostEventsController < ApplicationController
  respond_to :html, :xml, :json

  def index
    @events = PostEvent.find_for_post(params[:post_id])
    respond_with(@events)
  end
end
