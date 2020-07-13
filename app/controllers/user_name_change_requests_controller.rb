class UserNameChangeRequestsController < ApplicationController
  respond_to :html, :json, :xml

  def new
    @change_request = authorize UserNameChangeRequest.new(permitted_attributes(UserNameChangeRequest))
    respond_with(@change_request)
  end

  def create
    @change_request = authorize UserNameChangeRequest.new(user: CurrentUser.user, original_name: CurrentUser.name)
    @change_request.update(permitted_attributes(@change_request))
    flash[:notice] = "Your name has been changed" if @change_request.valid?
    respond_with(@change_request, location: profile_path)
  end

  def show
    @change_request = authorize UserNameChangeRequest.find(params[:id])
    respond_with(@change_request)
  end

  def index
    @change_requests = authorize UserNameChangeRequest.visible(CurrentUser.user).paginated_search(params)
    respond_with(@change_requests)
  end
end
