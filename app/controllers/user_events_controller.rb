# frozen_string_literal: true

class UserEventsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @defaults = { user_id: params[:user_id] }
    @mode = params[:mode] || (params[:user_id].present? ? "list" : "table")
    @user_events = authorize UserEvent.visible(CurrentUser.user).paginated_search(params, count_pages: true, defaults: @defaults)

    if request.format.html?
      @user = User.find(params[:user_id]) if params[:user_id].present?
      @user_events = @user_events.includes(:user, :ip_geolocation)
    end

    respond_with(@user_events)
  end
end
