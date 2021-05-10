class UserEventsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @user_events = authorize UserEvent.visible(CurrentUser.user).paginated_search(params, count_pages: true)
    @user_events = @user_events.includes(:user, user_session: [:ip_geolocation]) if request.format.html?

    respond_with(@user_events)
  end
end
