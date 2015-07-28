class PostEventsController < ApplicationController
  before_filter :member_only

  def index
    @events = PostEvent.find_for_post(params[:post_id])
  end
end
