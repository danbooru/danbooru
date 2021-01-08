class UserSessionsController < ApplicationController
  respond_to :html, :json, :xml

  def index
    @user_sessions = authorize UserSession.visible(CurrentUser.user).paginated_search(params, count_pages: true)

    respond_with(@user_sessions)
  end
end
