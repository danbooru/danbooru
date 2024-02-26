# frozen_string_literal: true

class UserEventsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @defaults = { user_id: params[:user_id] }
    @user_events = authorize UserEvent.visible(CurrentUser.user).paginated_search(params, count_pages: true, defaults: @defaults)
    @user_events = @user_events.includes(:user, :ip_geolocation) if request.format.html?

    respond_with(@user_events)
  end
end
