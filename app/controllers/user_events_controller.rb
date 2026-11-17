# frozen_string_literal: true

class UserEventsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    user_id = params.expect(:user_id) if params[:user_id].present?
    @defaults = { user_id: user_id }
    @mode = params[:mode] || (user_id.present? ? "list" : "table")
    @user_events = authorize UserEvent.visible(CurrentUser.user).paginated_search(params, count_pages: true, defaults: @defaults)

    if request.format.html?
      @user = User.find(user_id) if user_id.present?
      @user_events = @user_events.includes(:user, :ip_geolocation)
    end

    respond_with(@user_events)
  end
end
